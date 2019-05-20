
#include "System.h"
#include "misc_v4.h"

using namespace std;

void System::load(Rcpp::List args) {
  
  // split argument lists
  Rcpp::List args_params = args["args_params"];
  Rcpp::List args_functions = args["args_functions"];
  Rcpp::List args_progress = args["args_progress"];
  Rcpp::List args_progress_burnin = args_progress["pb_burnin"];
  
  // data
  x = rcpp_to_vector_double(args_params["x"]);
  
  // model parameters
  theta_init = rcpp_to_vector_double(args_params["theta_init"]);
  theta_min = rcpp_to_vector_double(args_params["theta_min"]);
  theta_max = rcpp_to_vector_double(args_params["theta_max"]);
  trans_type = rcpp_to_vector_int(args_params["trans_type"]);
  d = theta_init.size();
  
  // MCMC parameters
  burnin = rcpp_to_vector_int(args_params["burnin"]);
  samples = rcpp_to_int(args_params["samples"]);
  rungs = rcpp_to_int(args_params["rungs"]);
  burnin_phases = rcpp_to_int(args_params["burnin_phases"]);
  bw_update = rcpp_to_vector_bool(args_params["bw_update"]);
  cov_update = rcpp_to_vector_bool(args_params["cov_update"]);
  coupling_on = rcpp_to_vector_bool(args_params["coupling_on"]);
  GTI_pow = rcpp_to_double(args_params["GTI_pow"]);
  chain = rcpp_to_int(args_params["chain"]);
  
  // misc parameters
  pb_markdown = rcpp_to_bool(args_params["pb_markdown"]);
  silent = rcpp_to_bool(args_params["silent"]);
  
}