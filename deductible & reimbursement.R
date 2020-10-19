#The main purpose of this file is to try to find one of the common ways of insurance fraud: waiving deductible 
#amount. Since beneficiaries will be happy if they don't need to pay deductible amount of their claim, it is 
#very unlikely the beneficiary will report. So, some providers do waive patients' deductibles or co-payments and 
#then submit other false claims to insurance companies to make up the dollar difference.
#By Medicare policies, the inpatient deductible amount is fixed as $1068 for everytime the beneficiary is formally
#admitted into the hospital in 2009. Therefore, it is highly unlikely that inpatient deductible amount has any 
#indication of fradulent activites. Also, the only data that does not match is between deductible amount (outpatient)
#and the annual outpatient deductible amount.

'getting full data and removing irrelevant variables'
setwd("/Users/sunny/Desktop/Datathon 2020 data")
full <- read.csv(file = 'full_data.csv')
full_selected <- subset(full, select = c(BID, CID, PID, AmtReimbursed, DeductibleAmt, patient_type, Fraud,
                                         NumOfMonths_PartACov, NumOfMonths_PartBCov, 
                                         InpatientAnnualReimbursementAmt:OutpatientAnnualDeductibleAmt))

'checking matching rates for other three variables'


'creating randomized samples of size 10000 from the full data'
sample_full_selected <- full_selected[sample(1:nrow(full_selected), 100000, replace = FALSE), ]
  
'generating categories for outpatient deductible and outpatient reimbursement'
for (i in 1:100000){
  if(sample_full_selected$OutpatientAnnualDeductibleAmt[i] == 0){
    sample_full_selected$d[i] = 0}
  else if(sample_full_selected$OutpatientAnnualReimbursementAmt[i] >= sample_full_selected$OutpatientAnnualDeductibleAmt[i]){
    sample_full_selected$d[i] = 1}
  else {
    sample_full_selected$d[i] = 2}
}

'calculating the percentage of detecting fraud in each category'
sample_full_selected_fraud <- subset(sample_full_selected, Fraud == "Yes", 
                                     select = c(BID:d))
perc_0 <- length(which(sample_full_selected_fraud$d == 0)) / length(which(sample_full_selected$d == 0))
perc_1 <- length(which(sample_full_selected_fraud$d == 1)) / length(which(sample_full_selected$d == 1))
perc_2 <- length(which(sample_full_selected_fraud$d == 2)) / length(which(sample_full_selected$d == 2))

fraud_percentage <- c(perc_0, perc_1, perc_2)
#This result is in consistence with the hypothesis that fraud is more likely be with little deductible amount.
#Orignially, I also want to test if there are any connections between reimbursement and deductible amount, but the 
#result shows none.

'calculating reimbursement to deductible ratio if deductible != 0, calculating difference otherwise'
for (i in 1:100000){
  if(sample_full_selected$OutpatientAnnualDeductibleAmt[i] == 0){
    sample_full_selected$ratiodiff[i] = 
      abs(sample_full_selected$OutpatientAnnualReimbursementAmt[i] - sample_full_selected$OutpatientAnnualDeductibleAmt[i])}
  else{
    sample_full_selected$ratiodiff[i] = 
      sample_full_selected$OutpatientAnnualReimbursementAmt[i] / sample_full_selected$OutpatientAnnualDeductibleAmt[i]}
}

sample_full_selected_fraud <- subset(sample_full_selected, Fraud == "Yes", 
                                     select = c(BID:ratiodiff))
sample_full_selected_nonfraud <- subset(sample_full_selected, Fraud == "No", 
                                        select = c(BID:ratiodiff))

'checking distribution given fraud and nonfraud'
plot(density(sample_full_selected_fraud$ratiodiff))
plot(density(sample_full_selected_nonfraud$ratiodiff))
#no difference

sample_full_selected_fraud_diff <- subset(sample_full_selected, 
                                          Fraud == "Yes" & sample_full_selected$OutpatientAnnualDeductibleAmt == 0, 
                                          select = c(BID:ratiodiff))
sample_full_selected_nonfraud_diff <- subset(sample_full_selected, 
                                          Fraud == "No" & sample_full_selected$OutpatientAnnualDeductibleAmt == 0, 
                                          select = c(BID:ratiodiff))
sample_full_selected_fraud_ratio <- subset(sample_full_selected, 
                                           Fraud == "Yes" & sample_full_selected$OutpatientAnnualDeductibleAmt != 0, 
                                           select = c(BID:ratiodiff))
sample_full_selected_nonfraud_ratio <- subset(sample_full_selected, 
                                             Fraud == "No" & sample_full_selected$OutpatientAnnualDeductibleAmt != 0, 
                                             select = c(BID:ratiodiff))

'comparing distributions'
install.packages("sm")
library("sm")
#update.packages(checkBuilt = TRUE, ask = FALSE)
sm.density.compare(sample_full_selected_fraud_diff$ratiodiff, sample_full_selected_nonfraud_diff$ratiodiff, 
                   xlab="diff") 
title(main="diff distribution")
sm.density.compare(sample_full_selected_fraud_ratio$ratiodiff, sample_full_selected_nonfraud_ratio$ratiodiff, 
                   xlab="ratio") 
title(main="ratio distribution")

