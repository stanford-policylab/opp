data {
  int<lower=1> n_observations;
  int<lower=1> n_races;
  int<lower=1, upper=n_races> race[n_observations];
  int<lower=1> max_bunching_excess_speed;
  int<lower=0, upper=max_bunching_excess_speed>
    bunching_excess_speed[n_observations];
  vector[n_observations] leniency;
}

parameters {
  vector<lower=0>[n_races] lambda_race; 
  vector[n_races] beta_race;
  real<upper=0> beta_bunching_excess_speed;
  real<lower=0> beta_leniency;
}

model {
  lambda_race ~ normal(5, 5);
  beta_bunching_excess_speed ~ normal(0, 1);
  beta_race ~ normal(0, 1);
  beta_leniency ~ normal(0, 1);
  
  for (obs in 1:n_observations) {
    if (bunching_excess_speed[obs] > 0) {
      real p_discount = inv_logit(
        beta_bunching_excess_speed * bunching_excess_speed[obs]
        + beta_leniency * leniency[obs]
        + beta_race[race[obs]]
      );
      bunching_excess_speed[obs] ~
        poisson(lambda_race[race[obs]]) T[, max_bunching_excess_speed];
      0 ~ bernoulli(p_discount);
    } else {
      // excess speed at the bunching point
      vector[max_bunching_excess_speed + 1] log_pr_vec;
      // trucated poisson
      log_pr_vec[1] = poisson_lpmf(0 | lambda_race[race[obs]])
        - poisson_lcdf(max_bunching_excess_speed | lambda_race[race[obs]]);
      for (s in 1:max_bunching_excess_speed) {
        real p_discount = inv_logit(
          beta_bunching_excess_speed * s
          + beta_leniency * leniency[obs]
          + beta_race[race[obs]]
        );
        // trucated poisson
        log_pr_vec[s+1] = poisson_lpmf(s | lambda_race[race[obs]]) 
          - poisson_lcdf(max_bunching_excess_speed | lambda_race[race[obs]])
          + log(p_discount);
      }
      target += log_sum_exp(log_pr_vec);
    }
  }
}
