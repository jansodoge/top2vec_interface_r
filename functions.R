library(reticulate)
library(tidyverse)


#setup reticulate
#reticulate::use_python("/home/jan/anaconda3/envs/machine_learning_nlp/bin/python")
reticulate::source_python("functions.py")



get_number_of_topics <- function(model) get_top_number(model[1][[1]])

get_topic_sizes <- function(model){
py_get_topic_sizes(model[1][[1]]) %>% 
  purrr::set_names(c("observations_per_topic", "topic_number")) %>% 
  dplyr::bind_cols() %>% 
  dplyr::select(2, 1)
}

get_topics <- function(model, max_number_topics = "all"){
  topics <- py_get_topics(model[1][[1]])
  if (max_number_topics == "all") max_number_topics <- length(topics[[1]])
  purrr::pmap_dfr(list(topics[1][[1]][1:max_number_topics], 
                       topics[2][[1]][1:max_number_topics], 
                       topics[3][[1]][1:max_number_topics]),
              ~tibble(
                topic_number = ..3,
                word = ..1, 
                score = ..2,
                )
              )
}

#get_topics(model, 30)

get_similar_words <- function(model, word_selected, number_of_words = 10){
  number_of_words <- as.integer(number_of_words)
  py_get_similar_words(model[1][[1]],
                       word_selected,
                       number_of_words) %>% 
    purrr::set_names(c("word", "similarity")) %>% 
    dplyr::bind_cols()
}

#get_similar_words(model, "invandring", number_of_words = 10)

get_topics_per_document <- function(model, document_ids){
  purrr::map(document_ids,
             ~topics_per_document(model[1][[1]], .x) %>% 
               map2_dfc(c("score", "topic"), ~purrr::set_names(.x, .y)) 
             ) %>% 
    purrr::set_names(str_c("document_id:", document_ids, sep = ""))
}
