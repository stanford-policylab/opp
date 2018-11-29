data {
  int<lower=1> n_observations;
  int<lower=1> n_races;
  int<lower=1, upper=n_races> race[n_observations];
  int<lower=1> max_bunching_excess_speed;
  vector<lower=0, upper=max_bunching_excess_speed>[n_observations]
    bunching_excess_speed;
  vector<lower=0, upper=1>[n_observations] leniency;
}

parameters {
  vector[n_races] mu_race;
  vector[n_races] beta_race;
  real<upper=0> beta_bunching_excess_speed;
  real<lower=0> beta_leniency;
}

transformed parameters {
  vector[n_observations] pr_bunching_excess_speed = 
    poisson_lpmf(0 | mu_race);
  // for stops at bunching point
  for (i in 1:max_bunching_excess_speed) {
    pr_bunching_excess_speed = log_sum_exp(
      pr_bunching_excess_speed,
      poisson_lpmf(i | mu_race)
      + log(inv_logit(
        beta_bunching_excess_speed * i
        + beta_race[race]
        + beta_leniency * leniency
      ))
    );
  }
  // correction for stops not at bunching point
  for (i in 1:n_observations) {
    if bunching_excess_speed[i] > 0 {
      pr_bunching_excess_speed[i] =
        poisson_lpmf(bunching_excess_speed | mu_race)
        + log(1 - inv_logit(
          beta_bunching_excess_speed * bunching_excess_speed
          + beta_race[race]
          + beta_leniency * leniency
          )
        );
    }
  }
}

model {
  mu_race ~ normal(0, 1);
  beta_bunching_excess_speed ~ normal(0, 1);
  beta_race ~ normal(0, 1);
  beta_leniency ~ normal(0, 1);
  target += pr_bunching_excess_speed;
}
