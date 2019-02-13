data {
  int<lower=1> n_groups;
  int<lower=1> n_races;
  int<lower=1> n_sub_geographies;

  int<lower=1, upper=n_races> race[n_groups];
  int<lower=1, upper=n_sub_geographies> sub_geography[n_groups];
  int<lower=0,upper=1> legal[n_groups]; // is marijuana legal?
  // vector<lower=0,upper=1>[n_groups] legal; // is marijuana legal?
  
  int<lower=1> stop_count[n_groups];
  int<lower=0> search_count[n_groups];
  int<lower=0> hit_count[n_groups];
}

parameters {
  // standard deviation for threshold
  real<lower=0> sigma_threshold;
  
  // search thresholds
  vector[n_races] threshold_race;
  vector[n_groups] threshold_raw;
  
  vector[n_races] threshold_legal_race;
  vector[n_races] phi_legal_race;
  vector[n_races] delta_legal_race;

  // parameters for signal distribution
  vector[n_races] phi_race;
  vector[n_sub_geographies - 1] phi_sub_geography_raw;
  real mu_phi;

  vector[n_races] delta_race;
  vector[n_sub_geographies - 1] delta_sub_geography_raw;
  real mu_delta;
}

transformed parameters {
  vector[n_sub_geographies] phi_sub_geography;
  vector[n_sub_geographies] delta_sub_geography;
  vector[n_groups] phi;
  vector[n_groups] delta;
  vector[n_groups] threshold;
  vector<lower=0, upper=1>[n_groups] search_rate;
  vector<lower=0, upper=1>[n_groups] hit_rate;
  real successful_search_rate;
  real unsuccessful_search_rate;

  phi_sub_geography[1] = 0;
  phi_sub_geography[2:n_sub_geographies] = phi_sub_geography_raw;
  delta_sub_geography[1] = 0;
  delta_sub_geography[2:n_sub_geographies] = delta_sub_geography_raw;

  // threshold = threshold_race[race]
  //   + threshold_raw * sigma_threshold 
  //   + legal * threshold_legal_race[race];

  for (i in 1:n_groups) {
    threshold[i] = threshold_race[race[i]]
      + threshold_raw[i] * sigma_threshold 
      + legal[i] * threshold_legal_race[race[i]];
    // phi is the proportion of race x who evidence behavior
    // indicated by the outcome, i.e. whites carrying a weapon
    phi[i] = inv_logit(phi_race[race[i]]
      + phi_sub_geography[sub_geography[i]]
      + legal[i] * phi_legal_race[race[i]]);

    // mu is the center of the `outcome` distribution
    delta[i] = exp(delta_race[race[i]]
      + delta_sub_geography[sub_geography[i]]
      + legal[i] * delta_legal_race[race[i]]);

    successful_search_rate =
      phi[i] * (1 - normal_cdf(threshold[i], delta[i], 1));
    unsuccessful_search_rate =
      (1 - phi[i]) * (1 - normal_cdf(threshold[i], 0, 1));
    search_rate[i] = successful_search_rate + unsuccessful_search_rate;
    hit_rate[i] = successful_search_rate / search_rate[i];
  }
}


model {
  // draw threshold parameters
  sigma_threshold ~ normal(0, 1);

  threshold_legal_race ~ normal(0, 1);
  phi_legal_race ~ normal(0, 1);
  delta_legal_race ~ normal(0, 1);
  
  // draw demographic parameters
  // each is centered at its own mu, and we allow for demographic heterogeneity
  mu_phi ~ normal(0, 1);
  mu_delta ~ normal(0, 1);
  
  phi_race ~ normal(mu_phi, 0.1);
  delta_race ~ normal(mu_delta, 0.1);
  threshold_race ~ normal(0, 1);

  // draw control division parameters (for un-pinned divisions)
  phi_sub_geography_raw ~ normal(0, 0.1);
  delta_sub_geography_raw ~ normal(0, 0.1);

  // thresholds
  threshold_raw ~ normal(0, 1);

  search_count ~ binomial(stop_count, search_rate);
  hit_count ~ binomial(search_count, hit_rate);
}

generated quantities {
  // Stop-weighted per-race parameters
  vector[n_races] final_thresholds;
  
  {
    vector[n_races] counts;
    vector[n_sub_geographies] dep_stops;
    
    final_thresholds = rep_vector(0, n_races);
    counts     = rep_vector(0, n_races);
    dep_stops  = rep_vector(0, n_sub_geographies);
    
    
    // calculate total stops per department
    for (i in 1:n_groups) {
      dep_stops[sub_geography[i]] = dep_stops[sub_geography[i]] + stop_count[i];
    }
    
    for (i in 1:n_groups) {
      final_thresholds[race[i]] = final_thresholds[race[i]] 
        + threshold_raw[i] * dep_stops[sub_geography[i]];
      counts[race[i]] = counts[race[i]] + dep_stops[sub_geography[i]];
    }
    final_thresholds = final_thresholds ./ counts;
  }
}