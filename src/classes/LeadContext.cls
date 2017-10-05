public with sharing class LeadContext {

    /**
     * The set of Status picklist values that are considered to imply that
     * the lead is an open lead.
     */
    public static final Set<String> OPEN_STATUS_SET = new Set<String> {
        'Not Started',
        'In Progress'
    };

    public static final Set<String> REOPEN_CLOSEREASON_SET = new Set<String> {
        'Nurture',
        'BDR Disqualified',
        'Language Barrier'
    };
}