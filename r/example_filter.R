matrix_row_apply <- function(value, f) {
  return(matrix(apply(value, 2, f), ncol = ncol(value)))
}

matrix_col_apply <- function(value, f) {
  return(matrix(apply(value, 1, f), nrow = nrow(value)))
}

src <- tibble(
  letter = c('a', 'b', 'c', 'd'),
  city = c('ny', 'ny', 'ny', 'ca'),
  admin = c('pre', 'pre', 'post', 'post'),
  value = array(c(1, 1.5, 2, 3, 4, 5.5, 6, 7), dim = c(4, 1024)))

out <- src %>% 
  filter(admin == 'post' | admin == 'pre') %>%
  group_by(across(all_of(c('city')))) %>%
  group_modify(~ tibble(value = matrix_row_apply(.x$value, mean)))

print(out)