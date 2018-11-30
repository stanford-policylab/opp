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
  vector[n_races] lambda_race; 
  vector[n_races] beta_race;
  real<upper=0> beta_bunching_excess_speed;
  real<lower=0> beta_leniency;
  
}

transformed parameters {
  
  vector[n_observations] pr_bunching_excess_speed;
  vector[max_bunching_excess_speed + 1] tmp;
  
  for (obs in 1:n_observations) {
    // for stops at bunching point
    tmp[1] = poisson_lpmf(0 | lambda_race[race[obs]])
      - poisson_lcdf(max_bunching_excess_speed | lambda_race[race[obs]]); // truncate poisson
    for (i in 1:max_bunching_excess_speed) {
      tmp[i+1] = poisson_lpmf(i | lambda_race[race[obs]]) 
        - poisson_lcdf(max_bunching_excess_speed | lambda_race[race[obs]]) // truncate poisson
        + log(inv_logit(
          beta_bunching_excess_speed * i
          + beta_race[race[obs]]
          + beta_leniency * leniency[obs]
        ));
    }
    pr_bunching_excess_speed[obs] = log_sum_exp(tmp);
    // correction for stops not at bunching point
    if (bunching_excess_speed[obs] > 0) {
      pr_bunching_excess_speed[obs] =
        poisson_lpmf(bunching_excess_speed[obs] | lambda_race[race[obs]])
        - poisson_lcdf(max_bunching_excess_speed | lambda_race[race[obs]]) // truncate poisson
        + log(1 - inv_logit(
          beta_bunching_excess_speed * bunching_excess_speed[obs]
          + beta_race[race[obs]]
          + beta_leniency * leniency[obs]
          )
        );
    }
  }
}

model {
  lambda_race ~ normal(5, 1);
  beta_bunching_excess_speed ~ normal(0, 1);
  beta_race ~ normal(0, 1);
  beta_leniency ~ normal(0, 1);
  
  target += pr_bunching_excess_speed;
}

