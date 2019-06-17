data {
  int<lower=1> n_groups;
  int<lower=1> n_races;
  int<lower=1> n_subgeographies;
  int<lower=1> n_geographies;
  
  int<lower=1, upper=n_races> race[n_groups];
  int<lower=1, upper=n_subgeographies> subgeography[n_groups];
  int<lower=1, upper=n_geographies*n_races> geography_race[n_groups];
  
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

  // parameters for signal distribution
  // vector[n_races] phi_race;
  vector[n_geographies * n_races] phi_race; // try race per city
  vector[n_subgeographies - 1] phi_subgeography_raw;
  real mu_phi;

  // vector[n_races] delta_race;
  vector[n_geographies * n_races] delta_race; // try race per city
  vector[n_subgeographies - 1] delta_subgeography_raw;
  real mu_delta;
}

transformed parameters {
  vector[n_subgeographies] phi_subgeography;
  vector[n_subgeographies] delta_subgeography;
  vector[n_groups] phi;
  vector[n_groups] delta;
  vector[n_groups] threshold;
  vector<lower=0, upper=1>[n_groups] search_rate;
  vector<lower=0, upper=1>[n_groups] hit_rate;
  real successful_search_rate;
  real unsuccessful_search_rate;

  phi_subgeography[1] = 0;
  phi_subgeography[2:n_subgeographies] = phi_subgeography_raw;
  delta_subgeography[1] = 0;
  delta_subgeography[2:n_subgeographies] = delta_subgeography_raw;

  threshold = threshold_race[race]
    + threshold_raw * sigma_threshold;

  for (i in 1:n_groups) {
    // phi is the proportion of race x who evidence behavior
    // indicated by the outcome, i.e. whites carrying a weapon
    // phi[i] = inv_logit(phi_race[race[i]]
    phi[i] = inv_logit(phi_race[geography_race[i]] // try race per city
      + phi_subgeography[subgeography[i]]);

    // mu is the center of the `outcome` distribution
    // delta[i] = exp(delta_race[race[i]]
    delta[i] = exp(delta_race[geography_race[i]] // try race per city
      + delta_subgeography[subgeography[i]]);

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

  // draw demographic parameters
  // each is centered at its own mu, and we allow for demographic heterogeneity
  mu_phi ~ normal(0, 1);
  mu_delta ~ normal(0, 1);
  
  phi_race ~ normal(mu_phi, 0.1);
  delta_race ~ normal(mu_delta, 0.1);
  threshold_race ~ normal(0, 1);

  // draw control division parameters (for un-pinned divisions)
  phi_subgeography_raw ~ normal(0, 0.1);
  delta_subgeography_raw ~ normal(0, 0.1);

  // thresholds
  threshold_raw ~ normal(0, 1);

  search_count ~ binomial(stop_count, search_rate);
  hit_count ~ binomial(search_count, hit_rate);
}
