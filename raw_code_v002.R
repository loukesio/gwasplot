chr_centers_scaled <- gwas_plot_data %>%
  group_by(chr) %>%
  summarise(center = mean(x_gwas)) %>%
  pull(center)

network_base +
  # First layer: everything EXCEPT network genes
  geom_point(data = gwas_plot_data %>% filter(!gene %in% ALL_NETWORK_GENES),
             aes(x = x_gwas, y = y_gwas), color="#666666",
             alpha = 0.75, size = 4, shape = 19) +

  # Second layer: ONLY network genes
  geom_point(data = gwas_plot_data %>% filter(gene %in% ALL_NETWORK_GENES) %>%
               filter(neg_log10_p > 6),
             aes(x = x_gwas, y = y_gwas),
             color = "#d1422f", size = 5, shape = 19, alpha = 0.75) +

  # Add connection lines (only for significant genes)
  geom_segment(data = connection_data,
               aes(x = x_gwas, y = y_gwas, xend = x_net, yend = y_net),
               color = "#f4ab5c", linetype = "dotted", size = 1.2, alpha = 0.9,
               inherit.aes = FALSE) +

  # Add labels for network genes in GWAS section (like standalone plot)
  geom_text(data = gwas_plot_data %>% filter(gene %in% ALL_NETWORK_GENES) %>%
              filter(neg_log10_p > 6),
            aes(x = x_gwas, y = y_gwas, label = gene),
            vjust = -0.8, hjust = 0.5, size = 3, fontface = "bold", color = "darkred",
            inherit.aes = FALSE) +

  # Significance threshold line
  annotate("segment",
           x = min(gwas_plot_data$x_gwas),
           xend = max(gwas_plot_data$x_gwas),
           y = scales::rescale(7.3,
                               from = range(final_gwas_data$neg_log10_p),
                               to = c(net_y_range[1] - gwas_y_offset - gwas_height,
                                      net_y_range[1] - gwas_y_offset)),
           yend = scales::rescale(7.3,
                                  from = range(final_gwas_data$neg_log10_p),
                                  to = c(net_y_range[1] - gwas_y_offset - gwas_height,
                                         net_y_range[1] - gwas_y_offset)),
           linetype = "33",
           color = "#d1422f",
           alpha = 0.8,
           linewidth = 0.8,
           lineend = "butt"
  ) +

  # Section separator limited to data area
  annotate("segment",
           x = min(gwas_plot_data$x_gwas),
           xend = max(gwas_plot_data$x_gwas),
           y = net_y_range[1] - gwas_y_offset/2,
           yend = net_y_range[1] - gwas_y_offset/2,
           linetype = "solid",
           color = "grey98",
           alpha = 0.75,
           size = 1) +

  # FIX: Remove scale_y_continuous and scale_x_continuous (they might be conflicting)
  # Instead, add x-axis labels manually

  # Add x-axis labels for chromosomes
  annotate("text",
           x = chr_centers_scaled,
           y = net_y_range[1] - gwas_y_offset - gwas_height - 0.5,  # Position below the plot
           label = paste("Chr", 1:n_chromosomes),
           size = 3.5,
           hjust = 0.5) +

  # Add x-axis ticks (moved down to avoid hitting points)
  annotate("segment",
           x = chr_centers_scaled,
           xend = chr_centers_scaled,
           y = net_y_range[1] - gwas_y_offset - gwas_height - 0.3,  # Start further down
           yend = net_y_range[1] - gwas_y_offset - gwas_height - 0.2,  # End further down
           color = "black",
           size = 0.5) +

  # Add x-axis line (optional, for clarity)
  # annotate("segment",
  #          x = min(gwas_plot_data$x_gwas),
  #          xend = max(gwas_plot_data$x_gwas),
  #          y = net_y_range[1] - gwas_y_offset - gwas_height - 0.2,
  #          yend = net_y_range[1] - gwas_y_offset - gwas_height - 0.2,
  #          color = "black",
  #          size = 0.3) +

  # Y-AXIS LABEL FOR CO-EXPRESSION NETWORK
  annotate("text",
           x = net_x_range[1] - 1,
           y = mean(net_y_range),
           label = "Gene Co-expression Network",
           size = 4,
           angle = 90,
           vjust = 0.5,
           fontface = "bold",
           color = "black") +

  # Y-AXIS LABEL FOR GWAS
  annotate("text",
           x = net_x_range[1] - 1,
           y = net_y_range[1] - gwas_y_offset - gwas_height/2,
           label = expression(bold(GWAS~-log[10](P))),
           size = 4,
           angle = 90,
           vjust = 0.5,
           parse = TRUE) +

  # Y-axis tick marks and labels for GWAS section
  annotate("text", x = net_x_range[1] - 0.3,
           y = scales::rescale(c(0, 5, 10, 12),
                               from = range(final_gwas_data$neg_log10_p),
                               to = c(net_y_range[1] - gwas_y_offset - gwas_height,
                                      net_y_range[1] - gwas_y_offset)),
           label = c("0", "5", "10", "12"), size = 3, hjust = 1) +

  # Y-axis tick marks
  annotate("segment",
           x = net_x_range[1] - 0.27, xend = net_x_range[1] - 0.22,
           y = scales::rescale(c(0, 5, 10, 12),
                               from = range(final_gwas_data$neg_log10_p),
                               to = c(net_y_range[1] - gwas_y_offset - gwas_height,
                                      net_y_range[1] - gwas_y_offset)),
           yend = scales::rescale(c(0, 5, 10, 12),
                                  from = range(final_gwas_data$neg_log10_p),
                                  to = c(net_y_range[1] - gwas_y_offset - gwas_height,
                                         net_y_range[1] - gwas_y_offset)),
           color = "black", size = 0.5) +

  labs(
    title = "Integrated GWAS-Network Analysis",
    subtitle = paste("Orange dotted lines connect", nrow(connection_data), "GWAS-significant genes to network"),
    caption = paste("Hub gene", HUB_GENE, "is central in network but missed by GWAS")
  ) +

  # EXPAND BOTH x and y limits to make room for labels
  coord_cartesian(
    xlim = c(net_x_range[1] - 2, net_x_range[2] + 0.5),  # Extra space on left
    ylim = c(net_y_range[1] - gwas_y_offset - gwas_height - 0.8, net_y_range[2] + 0.8)  # Extra space top and bottom
  ) +

  guides(color = guide_legend(title = "Element Type", override.aes = list(alpha = 1, size = 4), ncol = 3)) +
  theme(legend.position = "none")

