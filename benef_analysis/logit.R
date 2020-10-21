library(tidyverse)
library(caret)

setwd('~/Desktop/final_yr/case_comp/Datathon2020/')

benef <- read.csv('./cleaned_data/benef_final.csv')
ID <- read.csv('./cleaned_data/extra_benef.csv')
fraud_label <- read.csv('./web_app/data/final.csv')

benef_extra <- benef %>% cbind(ID[,-1])
benef_label <- benef_extra %>% cbind(fraud_label[,c(1,24)])

benef1 <- benef_label[, -c(26,24)]

benef_final <- benef1 %>% group_by(BID) %>%
  summarise(Gender = first(Gender),
         Is_inpatient = first(Is_inpatient),
         Age = first(Age),
         Race = first(Race),
         State=first(State),
         County=first(County),
         Chronic_Alzheimer = first(Chronic_Alzheimer),
         Chronic_Heartfailure = first(Chronic_Heartfailure),
        Chronic_KidneyDisease = first(Chronic_KidneyDisease),
        Chronic_Cancer = first(Chronic_Cancer),
        Chronic_ObstrPulmonary = first(Chronic_ObstrPulmonary),
        Chronic_Depression = first(Chronic_Depression),
        Chronic_Diabetes = first(Chronic_Diabetes),
        Chronic_IschemicHeart = first(Chronic_IschemicHeart),
        Chronic_Osteoporasis = first(Chronic_Osteoporasis),
        Chronic_rheumatoidarthritis = first(Chronic_rheumatoidarthritis),
        Chronic_stroke = first(Chronic_stroke),
        RenalDisease = first(RenalDisease),
        FullYearPlanA = first(FullYearPlanA),
        FullYearPlanB = first(FullYearPlanB),
        ChronicDisease_Num = first(ChronicDisease_Num),
        NumOfClaims = n(),
        #NumOfProviders = n_distinct(PID),
        NumOfNonFraud = sum(union_real==-1),
        NumOfPotentialFraud = sum(union_real==0),
        NumOfRealFraud = sum(union_real==1)
        #,
        #Has_Fraud = case_when(NumFraud>0 ~ 1,
         #                     Has_RealFraud>0 ~ 1,
          #          TRUE ~ 0)
        )

##confirming 
fraud_policyholder <- benef %>% filter(Fraud == 1)
length(unique(fraud_policyholder$BID)) == sum(benef1$Has_Fraud)
## TRUE 


## export new df 
#write_csv(benef1, './cleaned_data/benef_final_fix.csv')

set.seed(123)
train_ind <- sample(seq_len(nrow(benef1)), size = floor(0.7 * nrow(benef)))

training <- benef[train_ind, ]
testing <- benef[-train_ind, ]
 
diseases <- glm(Has_Fraud ~ Chronic_Alzheimer+Chronic_Heartfailure+       
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
testing$Has_Fraud <- testing$Has_Fraud %>% as.factor()

confusionMatrix(testing$pred, testing$Has_Fraud)
## never predicts true cases .. abort model