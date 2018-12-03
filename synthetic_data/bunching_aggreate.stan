data {
  int<lower=1> n_groups;
  int<lower=1> max_bunching_excess_speed;
  int<lower=1> count[n_groups];
  int<lower=0, upper=max_bunching_excess_speed>
    bunching_excess_speed[n_groups];
  vector[n_groups] leniency;
  int<lower=0, upper=1> is_majority[n_groups];
}

parameters {
  real intercept;
  vector<lower=0>[2] lambda;
  real beta_majority;
  real<upper=0> beta_bunching_excess_speed;
  real<lower=0> beta_leniency;
}

model {
  intercept ~ normal(0, 1);
  lambda ~ normal(5, 5);
  beta_bunching_excess_speed ~ normal(0, 1);
  beta_leniency ~ normal(0, 1);
  beta_majority ~ normal(0, 1);

  for (i in 1:n_groups) {
    if (bunching_excess_speed[i] > 0) {
      real p_discount = inv_logit(
          intercept
          + beta_bunching_excess_speed * bunching_excess_speed[i]
          + beta_leniency * leniency[i]
          + beta_majority * is_majority[i]
      );
      target += (
        poisson_lpmf(bunching_excess_speed[i] | lambda[is_majority[i]])
        - poisson_lcdf(max_bunching_excess_speed | lambda[is_majority[i]])
        + log(1 - p_discount)
      ) * count[i];
    } else {
      vector[max_bunching_excess_speed + 1] log_pr_vec;
      # NOTE: truncated poisson
      log_pr_vec[1] = poisson_lpmf(0 | lambda[is_majority[i]])
        - poisson_lcdf(max_bunching_excess_speed | lambda[is_majority[i]]);
      for (s in 1:max_bunching_excess_speed) {
        real p_discount = inv_logit(
          intercept
          + beta_bunching_excess_speed * s
          + beta_leniency * leniency[i]
          + beta_majority * is_majority[i]
        );
        # NOTE: truncated poisson
        log_pr_vec[s + 1] = poisson_lpmf(s | lambda[is_majority[i]])
          - poisson_lcdf(max_bunching_excess_speed | lambda[is_majority[i]])
          + log(p_discount);
      }
      target += log_sum_exp(log_pr_rev) * count[i];
    }
  }
}
