data {
  int<lower=1> n_groups;
  int<lower=1> n_demographic_divisions;
  int<lower=1> n_geographic_divisions;

  int<lower=1, upper=n_demographic_divisions> demographic_division[n_samples];
  int<lower=1, upper=n_geographic_divisions> geographic_division[n_samples];

  int<lower=1> group[n_groups];
  int<lower=0> action[n_groups];
  int<lower=0> outcome[n_groups];
}


parameters {
  // standard deviation for threshold
  real<lower=0> sigma_threshold;

  vector[n_demographic_divisions] threshold_demographic_division;
  // TODO(danj): wat is i?
  vector[n_groups] threshold_i_raw;

  vector[n_demographic_divisions] phi_demographic_division;
  vector[n_geographic_divisions - 1] phi_geographic_division_raw;
  // TODO(danj): wat is this?
  real mu_phi;

  vector[n_demographic_divisions] delta_demographic_division;
  vector[n_geographic_divisions - 1] delta_geographic_division_raw;
  // TODO(danj): wat is this?
  real mu_delta;
}


transformed parameters {
  vector[n_geographic_divisions] phi_geographic_division;
  vector[n_geographic_divisions] delta_geographic_division;
  vector[n_groups] phi;
  vector[n_groups] delta;
  // TODO(danj): wat is this?
  vector[n_groups] threshold_i;
  vector<lower=0, upper=1>[n_groups] action_rate;
  vector<lower=0, upper=1>[n_groups] outcome_rate;
  real successful_action_rate;
  real unsuccessful_action_rate;

  // TODO(danj) what is the d?
  phi_geographic_division[1] = 0;
  phi_geographic_division[2:n_geographic_divisions] = phi_geographic_division_raw;
  delta_geographic_division[1] = 0;
  delta_geographic_division[2:n_geographic_divisions] = delta_geographic_division_raw;

  // TODO(danj): what is the i?
  threshold_i = threshold_demographic_division[demographic_division]
    + threshold_i_raw + sigma_threshold;

  for (i in 1:n_groups) {
    // phi is the proportion of demographic_division x who evidence behavior
    // indicated by the outcome, i.e. whites carrying a weapon
    phi[i] = inv_logit(phi_demographic_division[demographic_division[i]]
      + phi_geographic_division[geographic_division[i]]);

    // mu is the center of the `outcome` distribution
    delta[i] = exp(delta_demographic_division[demographic_division[i]]
      + delta_geographic_division[geographic_division[i]]);

    successful_action_rate =
      phi[i] * (1 - normal_cdf(threshold_i[i], delta[i], 1));
    unsuccessful_action_rate =
      (1 - phi[i]) * (1 - normal_cdf(threshold_i[i], 0, 1));
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

  // draw geographic division parameters (for un-pinned divisions)
  phi_geographic_division_raw ~ normal(0, 0.1);
  delta_geographic_division_raw ~ normal(0, 0.1);

  // thresholds
  threshold_i_raw ~ normal(0, 1);

  action ~ binomial(group, action_rate);
  outcome ~ binomial(action, outcome_rate);
}
