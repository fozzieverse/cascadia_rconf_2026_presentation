library(ggplot2)
library(tidyr)
library(dplyr)

benches <- vroom::vroom('./results/fuzzy_fozzie_string.csv')
benches$mem_alloc <- benches$mem_alloc / 1024 ^2
colnames(benches) <- c('Package', 'Method', 'Sample Size', 'Seconds', 'Peak Memory (MB)')

time_plot <- ggplot(benches, aes(x = factor(`Sample Size`), y = Seconds, fill = Package, group = Package)) +
  geom_col(position = position_dodge(width = 0.5), width = 0.5) +
  facet_wrap(Method ~ ., scales = "free_y") +
  labs(x = "Sample Size", y = "Median Seconds", fill = "Package") +
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
 scale_y_continuous(labels = scales::label_number(accuracy = 0.01)) +
 ggtitle('Execution Time of String Matching Methods', subtitle = 'fozziejoin vs. fuzzyjoin')

ggsave("results/fuzzy_fozzie_string_time.svg", plot = time_plot, device = "svg",
       width = 7, height = 7, units = "in", dpi = 300)

mem_plot <- ggplot(benches, aes(x = factor(`Sample Size`), y = `Peak Memory (MB)`, fill = Package, group = Package)) +
  geom_col(position = position_dodge(width = 0.5), width = 0.5) +
  facet_wrap(Method ~ ., scales = "free_y") +
  labs(x = "Sample Size", y = "Peak Memory (MB)", fill = "Package") +
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
 scale_y_continuous(labels = scales::label_number(accuracy = 0.01)) +
 ggtitle('Peak Memory Usage of String Matching Methods', subtitle = 'fozziejoin vs. fuzzyjoin')

ggsave("results/fuzzy_fozzie_string_mem.svg", plot = mem_plot, device = "svg",
       width = 7, height = 7.0, units = "in", dpi = 300)
