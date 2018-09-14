	data {
  int<lower=1> N_OBSERVATIONS;
  int<lower=1> N_SUSPECT_RACES;
  int<lower=1> N_GEOGRAPHIC_UNITS;

  int<lower=1,upper=N_SUSPECT_RACES> race[N_OBSERVATIONS];
  int<lower=1,upper=N_GEOGRAPHIC_UNITS> geographic_unit[N_OBSERVATIONS];

  int<lower=1> stops[N_OBSERVATIONS];
  int<lower=0> searches[N_OBSERVATIONS];
  int<lower=0> hits[N_OBSERVATIONS];
}

parameters {
  // hyperparameters
  real<lower=0> sigma_t; // std dev for the normal the thresholds are drawn from

  // search thresholds
  vector[N_SUSPECT_RACES] t_race;
  vector[N_OBSERVATIONS] t_i_raw;

  // parameters for signal distribution
  vector[N_SUSPECT_RACES] phi_race;
  vector[N_GEOGRAPHIC_UNITS-1] phi_geo_raw;
  real mu_phi;

  vector[N_SUSPECT_RACES] delta_race;
  vector[N_GEOGRAPHIC_UNITS-1] delta_geo_raw;
  real mu_delta;
}

transformed parameters {
  vector[N_GEOGRAPHIC_UNITS] phi_geo;
  vector[N_GEOGRAPHIC_UNITS] delta_geo;
  vector[N_OBSERVATIONS] phi;
  vector[N_OBSERVATIONS] delta;
  vector[N_OBSERVATIONS] t_i;
  vector<lower=0, upper=1>[N_OBSERVATIONS] search_rate;
  vector<lower=0, upper=1>[N_OBSERVATIONS] hit_rate;
  real successful_search_rate;
  real unsuccessful_search_rate;

  phi_geo[1] = 0;
  phi_geo[2:N_GEOGRAPHIC_UNITS] = phi_geo_raw;
  delta_geo[1] = 0;
  delta_geo[2:N_GEOGRAPHIC_UNITS] = delta_geo_raw;

  t_i = t_race[race] + t_i_raw * sigma_t;

  for (i in 1:N_OBSERVATIONS) {

    // phi is the fraction of people of race r, d who are guilty (carrying weapon)
    phi[i] = inv_logit(phi_race[race[i]] + phi_geo[geographic_unit[i]]);

    // mu is the center of the guilty distribution.
    delta[i] = exp(delta_race[race[i]] + delta_geo[geographic_unit[i]]);

    successful_search_rate = phi[i] * (1 - normal_cdf(t_i[i], delta[i], 1));
    unsuccessful_search_rate = (1 - phi[i]) * (1 - normal_cdf(t_i[i], 0, 1));
    search_rate[i] = (successful_search_rate + unsuccessful_search_rate);
    hit_rate[i] = successful_search_rate / search_rate[i];
  }
}

model {
  // Draw threshold hyperparameters
  sigma_t ~ normal(0, 1);

  // Draw race parameters.
  // Each is centered at a mu, and we allow for inter-race heterogeneity.
  mu_phi ~ normal(0, 1);
  mu_delta ~ normal(0, 1);

  phi_race ~ normal(mu_phi, .1);
  delta_race ~ normal(mu_delta, .1);
  t_race ~ normal(0, 1);

  // Draw geography parameters (for un-pinned geographic units)
  phi_geo_raw ~ normal(0, .1);
  delta_geo_raw ~ normal(0, .1);

  // Thresholds
  t_i_raw ~ normal(0, 1);

  searches ~ binomial(stops, search_rate);
  hits ~ binomial(searches, hit_rate);
}
