data {
  int<lower=1> n_groups;
  int<lower=1> n_demographic_divisions;
  int<lower=1> n_control_divisions;

  int<lower=1, upper=n_demographic_divisions> demographic_division[n_groups];
  int<lower=1, upper=n_control_divisions> control_division[n_groups];

  int<lower=1> group_count[n_groups];
  int<lower=0> action_count[n_groups];
  int<lower=0> outcome_count[n_groups];
}

parameters {
  // standard deviation for threshold
  real<lower=0> sigma_threshold;
  
  // action thresholds
  vector[n_demographic_divisions] threshold_demographic_division;
  vector[n_groups] threshold_raw;

  // parameters for signal distribution
  // vector[n_demographic_divisions] phi_demographic_division;
  vector[n_groups] phi_demographic_division; // try race per city
  vector[n_control_divisions - 1] phi_control_division_raw;
  real mu_phi;

  // vector[n_demographic_divisions] delta_demographic_division;
  vector[n_groups] delta_demographic_division; // try race per city
  vector[n_control_divisions - 1] delta_control_division_raw;
  real mu_delta;
}

transformed parameters {
  vector[n_control_divisions] phi_control_division;
  vector[n_control_divisions] delta_control_division;
  vector[n_groups] phi;
  vector[n_groups] delta;
  vector[n_groups] threshold;
  vector<lower=0, upper=1>[n_groups] action_rate;
  vector<lower=0, upper=1>[n_groups] outcome_rate;
  real successful_action_rate;
  real unsuccessful_action_rate;

  phi_control_division[1] = 0;
  phi_control_division[2:n_control_divisions] = phi_control_division_raw;
  delta_control_division[1] = 0;
  delta_control_division[2:n_control_divisions] = delta_control_division_raw;

  threshold = threshold_demographic_division[demographic_division]
    + threshold_raw * sigma_threshold;

  for (i in 1:n_groups) {
    // phi is the proportion of demographic_division x who evidence behavior
    // indicated by the outcome, i.e. whites carrying a weapon
    // phi[i] = inv_logit(phi_demographic_division[demographic_division[i]]
    phi[i] = inv_logit(phi_demographic_division[i] // try race per city
      + phi_control_division[control_division[i]]);

    // mu is the center of the `outcome` distribution
    // delta[i] = exp(delta_demographic_division[demographic_division[i]]
    delta[i] = exp(delta_demographic_division[i] // try race per city
      + delta_control_division[control_division[i]]);

    successful_action_rate =
      phi[i] * (1 - normal_cdf(threshold[i], delta[i], 1));
    unsuccessful_action_rate =
      (1 - phi[i]) * (1 - normal_cdf(threshold[i], 0, 1));
    action_rate[i] = successful_action_rate + unsuccessful_action_rate;
    outcome_rate[i] = successful_action_rate / action_rate[i];
  }
}


model {
  // draw threshold parameters
  sigma_threshold ~ normal(0, 1);

  // draw demographic parameters
  // each is centered at its own mu, and we allow for demographic heterogeneity
  mu_phi ~ normal(0, 1);
  mu_delta ~ normal(0, 1);
  
  phi_demographic_division ~ normal(mu_phi, 0.1);
  delta_demographic_division ~ normal(mu_delta, 0.1);
  threshold_demographic_division ~ normal(0, 1);

  // draw control division parameters (for un-pinned divisions)
  phi_control_division_raw ~ normal(0, 0.1);
  delta_control_division_raw ~ normal(0, 0.1);

  // thresholds
  threshold_raw ~ normal(0, 1);

  action_count ~ binomial(group_count, action_rate);
  outcome_count ~ binomial(action_count, outcome_rate);
}
