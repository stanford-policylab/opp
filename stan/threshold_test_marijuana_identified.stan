data {
  int<lower=1> n_groups;
  int<lower=1> n_races;
  int<lower=1> n_subgeographies;

  int<lower=1, upper=n_races> race[n_groups];
  int<lower=1, upper=n_subgeographies> subgeography[n_groups];
  int<lower=0,upper=1> legal[n_groups]; // is marijuana legal?

  int<lower=1> stop_count[n_groups];
  int<lower=0> search_count[n_groups];
  int<lower=0> hit_count[n_groups];
  
  real<lower=0> prior_scaling_factor;
}

parameters {
  // standard deviation for threshold
  real<lower=0> sigma_threshold_raw;
  
  // search thresholds
  vector[n_races] threshold_race_raw;
  vector[n_groups] threshold_raw;
  
  vector[n_races] threshold_legal_race;
  vector[n_races] phi_legal_race;
  vector[n_races] delta_legal_race;

  // parameters for signal distribution
  vector[n_races - 1]  phi_race_raw;
  vector[n_subgeographies - 1] phi_subgeography_raw;
  real mu_phi_raw;

  vector[n_races - 1] delta_race_raw;
  vector[n_subgeographies - 1] delta_subgeography_raw;
  real mu_delta_raw;
}

transformed parameters {
  vector[n_races] phi_race;
  vector[n_races] delta_race;
  vector[n_subgeographies] phi_subgeography;
  vector[n_subgeographies] delta_subgeography;
  vector[n_groups] phi;
  vector[n_groups] delta;
  vector[n_groups] threshold;
  vector[n_groups] threshold_race;
  vector<lower=0, upper=1>[n_groups] search_rate;
  vector<lower=0, upper=1>[n_groups] hit_rate;
  real successful_search_rate;
  real unsuccessful_search_rate;
  real<lower=0> sigma_threshold;
  real mu_phi;
  real mu_delta;

  mu_phi = mu_phi_raw * prior_scaling_factor;
  mu_delta = mu_delta_raw * prior_scaling_factor;
  
  phi_race[1] = 0;
  phi_race[2:n_races] = phi_race_raw * 0.1 * prior_scaling_factor;
  delta_race[1] = 0;
  delta_race[2:n_races] = delta_race_raw * 0.1 * prior_scaling_factor;

  phi_subgeography[1] = 0;
  phi_subgeography[2:n_subgeographies] = phi_subgeography_raw * 0.1 * prior_scaling_factor;
  delta_subgeography[1] = 0;
  delta_subgeography[2:n_subgeographies] = delta_subgeography_raw * 0.1 * prior_scaling_factor;

  threshold_race = threshold_race_raw[race] * prior_scaling_factor;
  sigma_threshold = sigma_threshold_raw * prior_scaling_factor;

  for (i in 1:n_groups) {
    threshold[i] = threshold_race[race[i]]
      + threshold_raw[i] * sigma_threshold 
      + legal[i] * threshold_legal_race[race[i]];
    // phi is the proportion of race x who evidence behavior
    // indicated by the outcome, i.e. whites carrying a weapon
    phi[i] = inv_logit(
      mu_phi
      + phi_race[race[i]]
      + phi_subgeography[subgeography[i]]
      + legal[i] * phi_legal_race[race[i]]);

    // mu is the center of the `outcome` distribution
    delta[i] = exp(
      mu_delta
      + delta_race[race[i]]
      + delta_subgeography[subgeography[i]]
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

  threshold_legal_race ~ normal(0, 1);
  phi_legal_race ~ normal(0, 1);
  delta_legal_race ~ normal(0, 1);
  
  // draw demographic parameters
  // each is centered at its own mu, and we allow for demographic heterogeneity
  mu_phi_raw ~ normal(0, 1);
  mu_delta_raw ~ normal(0, 1);
  
  phi_race_raw ~ normal(0, 1);
  delta_race_raw ~ normal(0, 1);
  threshold_race_raw ~ normal(0, 1);

  // draw control division parameters (for un-pinned divisions)
  phi_subgeography_raw ~ normal(0, 1);
  delta_subgeography_raw ~ normal(0, 1);

  // thresholds
  sigma_threshold_raw ~ normal(0, 1);
  threshold_raw ~ normal(0, 1);

  search_count ~ binomial(stop_count, search_rate);
  hit_count ~ binomial(search_count, hit_rate);
}

generated quantities {
  // Stop-weighted per-race parameters
  vector[n_races] final_thresholds;
  
  {
    vector[n_races] counts;
    vector[n_subgeographies] dep_stops;
    
    final_thresholds = rep_vector(0, n_races);
    counts     = rep_vector(0, n_races);
    dep_stops  = rep_vector(0, n_subgeographies);
    
    
    // calculate total stops per department
    for (i in 1:n_groups) {
      dep_stops[subgeography[i]] = dep_stops[subgeography[i]] + stop_count[i];
    }
    
    for (i in 1:n_groups) {
      final_thresholds[race[i]] = final_thresholds[race[i]] 
        + threshold_raw[i] * dep_stops[subgeography[i]];
      counts[race[i]] = counts[race[i]] + dep_stops[subgeography[i]];
    }
    final_thresholds = final_thresholds ./ counts;
  }
}
