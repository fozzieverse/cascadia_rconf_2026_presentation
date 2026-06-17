library(ggplot2)
library(tidyr)
library(dplyr)

benches <- vroom::vroom('./results/zoomer_fozzie_string.csv')
colnames(benches) <- c('Package', 'Method', 'Comparisons', 'Seconds', 'Peak Memory (MB)')

benches_long <- benches |> pivot_longer(
  cols=c('Seconds', 'Peak Memory (MB)'), names_to='metric', values_to = 'value'
) %>%
  mutate(
    value = ifelse(metric == 'Peak Memory (MB)', value / (1024 ^ 2), value),
    `Comparisons (Billions)` = round(Comparisons / 1e9, 2)
)

p <- ggplot(benches_long, aes(x = factor(`Comparisons (Billions)`), y = value, fill = Package, group = Package)) +
  geom_col(position = position_dodge(width = 0.5), width = 0.5) +
  facet_wrap(metric ~ Method, scales = "free") +
  labs(x = "Comparisons (Billions)", y = "Value", fill = "Package") +
  theme_classic(base_size = 12) +
  theme(
    strip.text = element_text(face = "bold", size = 12),
    axis.text.x = element_text(hjust = 0.5),
    axis.title.x = element_text(margin = margin(t = 10)),
    axis.title.y = element_text(margin = margin(r = 10)),
    legend.position = "bottom",
    legend.title = element_text(face = "bold"),
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    panel.grid.major.y = element_line(color = "grey85"),
    panel.border = element_rect(fill = NA, colour = "grey40"),
  ) +
 scale_fill_grey(start = 0.1, end = 0.6) +
 scale_y_continuous(labels = scales::label_number(accuracy = 0.1)) +
 ggtitle('Comparative benchmarks for select string distances', subtitle = 'fozziejoin vs. zoomerjoin')

ggsave("results/zoomer_fozzie_string.svg", plot = p, device = "svg",
       width = 7, height = 8.5, units = "in", dpi = 300)
