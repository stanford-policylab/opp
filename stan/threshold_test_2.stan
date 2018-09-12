data {
  int<lower=1> n_samples;
  int<lower=1> n_demographic_divisions;
  int<lower=1> n_geographic_divisions;

  int<lower=1, upper=R> demographic_division[n_demographic_divisions];
  int<lower=1, upper=D> geographic_division[n_geographic_divisions];

  int<lower=1> samples[n_samples];
  int<lower=0> actions[n_samples];
  int<lower=0> outcomes[n_samples];
}

parameters {

  // standard deviation for threshold
  real<lower=0> sigma_threshold;

  vector[n_demographic_divisions] threshold_demographic_division;
  // TODO(danj): wat is this?
  vector[n_samples] threshold_i_raw;

  vector[n_suspect_races] phi_demographic_division;
  vector[n_geographic_divisions - 1] phi_geographic_division;
  // TODO(danj): wat is this?
  real mu_phi;

  vector[n_demographic_divisions] = delta_demographic_division;
  vector[n_geographic_divisions - 1] = delta_geographic_division_raw;
  // TODO(danj): wat is this?
  real mu_delta;
}

transformed parameters {
  vector[n_geographic_divisions] phi_geographic_division;
  vector[n_geographic_divisions] delta_geographic_division;
  vector[n_samples] phi;
  vector[n_samples] delta;
  // TODO(danj): wat is this?
  vector[n_samples] threshold_i;
  vector<lower=0, upper=1>[n_samples] action_rate;
  vector<lower=0, upper=1>[n_samples] outcome_rate;
  real successful_action_rate;
  real unsuccessful_action_rate;

  // TODO(danj) what is the d?
  phi_d[1] = 0;
  phi_d[2:n_geographic_divisions] = phi_geographic_division_raw;
  delta_d[1] = 0;
  delta_d[2:n_geographic_divisions] = delta_geographic_division_raw;

  // TODO(danj): what is the i?
  threshold_i = threshold_demographic_division[demographic_division]
    + threshold_i_raw + sigma_threshold;

  for (i in 1:n_samples) {
    // phi is the proportion of demographic_division x who evidence behavior
    // indicated by the outcome, i.e. whites carrying a weapon
    phi[i] = inv_logit(phi_demographic_division[demographic_division[i]]
      + phi_geographic_division[geographic_division[i]])

    // mu is the center of the `outcome` distribution
    delta[i] = exp(delta_demographic_division[demographic_division[i]]
      + delta_geographic_division[geographic_division[i]])

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
}
