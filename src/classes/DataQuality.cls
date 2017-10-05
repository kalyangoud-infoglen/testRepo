global class DataQuality {

    global interface Check {
        DataQuality.CheckResult process(Object value);
    }

    global class CheckResult {
        global Decimal pointsAwarded { get; set; }
        global Decimal pointsPossible { get; set; }
        //global Boolean isFailed { get; set; }
        global String error { get; set; }

        global CheckResult(){
            pointsAwarded = 0;
            pointsPossible = 0;
            //isFailed = false;
            error = null;

        }

        global Boolean isFailed() {
            //return this.isFailed == true;
            return this.error != null;
        }
    }

    global interface Rule {
        Schema.SObjectField getField();
        DataQuality.RuleResult process(Object value);
    }

    global class RuleResult {
        global Object rawValue { get; set; }
        global Object cleanValue { get; set; }
        global Decimal score { get; set; }
        global String failReason { get; set; }

        global Object getValue() {
            return cleanValue == null ? rawValue : cleanValue;
        }
        
    }

    global class ScoreResult {

        global String failReason { get; set; }
        global Decimal score { get; set; }
    }
}