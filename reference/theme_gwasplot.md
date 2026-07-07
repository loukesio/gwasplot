# A clean theme for gwasplot figures

A minimal
[`ggplot2::theme_minimal()`](https://ggplot2.tidyverse.org/reference/ggtheme.html)-based
theme with no vertical grid lines, tidy axis titles and a subtle
significance-line look. Used by default in
[`gwas_manhattan()`](https://loukesio.github.io/gwasplot/reference/gwas_manhattan.md);
add or override it like any ggplot2 theme.

## Usage

``` r
theme_gwasplot(base_size = 12, base_family = "")
```

## Arguments

- base_size:

  Base font size, passed to
  [`ggplot2::theme_minimal()`](https://ggplot2.tidyverse.org/reference/ggtheme.html).

- base_family:

  Base font family.

## Value

A ggplot2 theme object.

## Examples

``` r
library(ggplot2)
ggplot(mtcars, aes(wt, mpg)) + geom_point() + theme_gwasplot()
```
