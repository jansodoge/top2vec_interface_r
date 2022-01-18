library(reticulate)
library(tidyverse)


#setup reticulate
reticulate::use_python("/home/jan/anaconda3/envs/machine_learning_nlp/bin/python")
reticulate::source_python("functions.py")




#load the top2vec model
top2vec_model <- read_top2vec("init_model_13_1_21")


number_topics <- get_top_number(top2vec_model[1][[1]])



get_number_of_topics <- function(model){
  get_top_number(model[1][[1]])
  
}





get_topic_sizes <- function(model){
topics_sizes <- py_get_topic_sizes(model[1][[1]]) %>% 
  dplyr::bind_cols() %>% 
  dplyr::rename(observations_per_topic = ...1,
                topic_number = ...2)
}





get_topics <- function(model, max_number_topics = "all"){
  
topics <- py_get_topics(model[1][[1]])
 topics_df <- purrr::map2(topics[1][[1]], topics[2][[1]], function(words, scores){
    data.frame(word = words, score = scores)
  }) %>% 
    purrr::map2_dfr(., topics[3][[1]], function(list_df, topic_number){
      list_df$topic_number <- rep(topic_number, 50) 
      return(list_df)
    })
 return(topics_df)
}




get_similiar_words <- function(model, word_selected, number_of_words = 10){
  number_of_words <- as.integer(number_of_words)
  py_get_similiar_words(model[1][[1]],
                        word_selected,
                        number_of_words) %>% 
    dplyr::bind_cols() %>% 
    dplyr::rename(word = ...1,
                  similiarity = ...2)
}





get_topics_per_document <- function(model, document){
  
  
  topics_per_document(model[1][[1]], document) %>% 
  dplyr::bind_cols() %>% 
  dplyr::rename(score = ...1,
                topic = ...2)

}



get_topics_per_documents <- function(model, document_ids){
  
  purrr::map_dfr(document_ids, function(document_id){
    
    
    get_topics_per_document(model, document_id) %>% 
      mutate(document  = document_id)
    
    
  })
  
  
}








