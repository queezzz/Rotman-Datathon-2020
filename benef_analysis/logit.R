library(tidyverse)
library(caret)

setwd('~/Desktop/final_yr/case_comp/Datathon2020/')

benef = read.csv('./cleaned_data/benef_final.csv')

set.seed(123)
train_ind <- sample(seq_len(nrow(benef)), size = floor(0.7 * nrow(benef)))

training <- benef[train_ind, ]
testing <- benef[-train_ind, ]
 
diseases <- glm(Fraud ~ Chronic_Alzheimer+Chronic_Heartfailure+       
               Chronic_KidneyDisease+Chronic_Cancer+
                 Chronic_ObstrPulmonary+Chronic_Depression+
               Chronic_Diabetes+Chronic_IschemicHeart+
                 Chronic_Osteoporasis+Chronic_rheumatoidarthritis+
                 Chronic_stroke, data=training,
               family='binomial')

summary(diseases)
#Chronic_KidneyDisease
#obstr pulmonary 
#Depression
#IschemicHeart 
#Stroke

testing <- testing %>% 
  mutate(y_pred = predict(diseases, testing, type='response'),
         pred = if_else(y_pred>0.5, 1, 0))

testing$pred <- testing$pred %>% as.factor()
testing$Fraud <- testing$Fraud %>% as.factor()

confusionMatrix(testing$pred, testing$Fraud)
## never predicts true cases .. abort model