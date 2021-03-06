# This prep_text function reads in a dataframe and requires two variable names
# one that describes the document name, and one that describes the text of
# the document. The node_type argument describes whether the user wants to
# create a network where the nodes are words within a document, or the nodes are the
# documents themselves. The function a) removes URLs; b) removes stop words, and c)
# stems words, and d) creates a summarized tidy text format (where each row of the # dataset describes the prevalence of each word within the document)

PrepText <-function(textdata, groupvar, textvar, node_type=c("groups","words"),
                     remove_url = FALSE, remove_stop_words=FALSE, stem=FALSE, remove_numbers=FALSE) {
  
  #remove URLS
  if (remove_url) {
    textdata[[textvar]]<-stringr::str_replace_all(textdata[[textvar]], "https?://t\\.co/[A-Za-z\\d]+|https?://[A-Za-z\\d]+|&amp;|&lt;|&gt;|RT|https?", "")
  }
  
  if (remove_numbers) {
    textdata[[textvar]]<-gsub("\\b\\d+\\b", "",textdata[[textvar]])
  }
  
  # remove extra whitespaces
  textdata[[textvar]] <- gsub("\\s+"," ",textdata[[textvar]])
  
  #remove texts that are entirely empty
  message(paste(as.character(nrow(filter(textdata, grepl("^\\s*$", textdata[[textvar]]))))), ' documents were removed because they are empty.')
  
  textdata <- filter(textdata, !grepl("^\\s*$", textdata[[textvar]])) 
  
  textdata <- textdata %>%
    select_(groupvar,textvar) %>%
    #tidy text
    unnest_tokens_("word", textvar)
  
  if (remove_stop_words){
    data("stop_words")
    textdata<-textdata %>%
      anti_join(stop_words)
  }
  
  if (stem){
    textdata<-textdata %>%
      mutate_at("word", funs(wordStem((.), language="en")))
  }
  
  textdata <- textdata %>%
    rename_(group = c(groupvar))
  
  if (node_type=="groups"){
    #count terms by document
    textdata<-textdata %>%
      group_by(group) %>%
      count(word) %>%
      rename(count=n)
  }
  
  if (node_type=="words"){
    textdata<-textdata %>%
      group_by(word) %>%
      count(group) %>%
      rename(count=n)
  }
  
  return(textdata)
}
