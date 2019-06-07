
#------------------------------------------------
#' @title Plot Metropolis Coupling Acceptance
#'
#' @description Plot Metropolis Coupling Acceptance.
#'
#' @param x an object of class \code{drjacoby_output}
#' @param chain which chain to plot.
#' @param phase which phase to plot. Must be either "burnin" or "sampling".
#'
#' @import ggplot2
#' @importFrom grDevices grey
#' @export

plot_mc_acceptance <- function(x, chain = 1, phase = "sampling") {
  
  # check inputs
  assert_custom_class(x, "drjacoby_output")
  assert_single_pos_int(chain)
  assert_leq(chain, length(x))
  assert_in(phase, c("burnin", "sampling"))
  
  # get values
  beta_raised <- x[[chain]]$diagnostics$beta_raised
  beta_raised_mid <- beta_raised[-1] - diff(beta_raised)/2
  if (phase == "burnin") {
    mc_accept <- x[[chain]]$diagnostics$mc_accept_burnin
  } else {
    mc_accept <- x[[chain]]$diagnostics$mc_accept_sampling
  }
  
  # produce plot
  plot1 <- ggplot() + theme_bw() + theme(panel.grid.minor.x = element_blank(),
                                         panel.grid.major.x = element_blank())
  plot1 <- plot1 + geom_vline(aes(xintercept = beta_raised), col = grey(0.9))
  plot1 <- plot1 + scale_x_continuous(limits = c(0,1)) + scale_y_continuous(limits = c(0,1), expand = c(0,0))
  plot1 <- plot1 + geom_point(aes(x = beta_raised_mid, y = mc_accept), col = "red")
  plot1 <- plot1 + xlab("thermodynamic power") + ylab("coupling acceptance rate")
  
  return(plot1)
}

#' @title Plot autocorrelation
#'
#' @description Plot autocorrelation for specified parameters
#'
#' @inheritParams plot_mc_acceptance
#' @param lag Maximum lag. Must be an integer between 20 and 500.
#' @param par Vector of parameter names. If NULL all parameters are plotted
#'
#'
#' @export
plot_autocorrelation <- function(x, lag = 20, par = NULL, chain = 1, phase = "sampling") {
  # check inputs
  assert_custom_class(x, "drjacoby_output")
  assert_single_pos_int(chain)
  assert_leq(chain, length(x))
  assert_in(phase, c("burnin", "sampling"))
  assert_single_bounded(lag, 1, 500)
  
  # get values
  if (phase == "burnin") {
    data <- x[[chain]]$theta_burnin$rung1
  } else {
    data <- x[[chain]]$theta_sampling$rung1
  }
  # Select parameters
  if(!is.null(par)){
    data <- data[, colnames(data) %in% par, drop = FALSE]
  }
  # Estimate autocorrelation
  out <- as.data.frame(apply(data, 2, acf_data, lag = lag))
  # Format data for plotting
  out$lag <- 0:lag
  out <- tidyr::gather(out, "parameter", "Autocorrelation", -lag)
  
  ggplot2::ggplot(data = out,
                  ggplot2::aes(x = .data$lag, y = 0, xend = .data$lag, yend =.data$Autocorrelation)) + 
    ggplot2::geom_hline(yintercept = 0, lty = 2, col = "red") + 
    ggplot2::geom_segment(size = 1.5) +
    ggplot2::theme_bw() +
    ggplot2::ylab("Autocorrelation") +
    ggplot2::xlab("Lag") +
    ggplot2::ylim(min(0, min(out$Autocorrelation)), 1) +
    ggplot2::facet_wrap(~ parameter)
}

