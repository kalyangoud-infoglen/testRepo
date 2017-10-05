/**
 * This abstract class is part of the core framework used to chain asynchronous
 * jobs together, originally designed to satisfy the needs of the Inbound
 * Lead Service for scrubbing, de-duplicating, validating, enriching, among
 * other steps before finally making a new lead visible to an end user.
 *
 * This class works together with the Async Job and Async Job Link custom
 * metadata types to chain jobs together. Every chainable job is first
 * enumerated with an Async Job record, and then the logical sequencing
 * of jobs is handled with Async Job Link records.
 *
 * This class works uses the Profiler class to monitor performance of the 
 * async job, tracking for example how long it takes to complete an instance
 * of this job or what percentage of such jobs fail.
 *
 * TODO: It would be cleaner to split the profiling logic and the async job
 *       logic perhaps into separate interfaces, but it's not clear how
 *       that would all come together into a single implementation yet.
 *       It would be nice for the job to be compatible with all three
 *       commonly used interfaces: Batchable, Scheduleable, Queueable.
 */
global abstract class AbstractProfiledAsyncJob implements Queueable {

    /**
     * This is the profiler that takes care of recording when a job starts,
     * ends. And if any errors are encountered the profiler also tracks that.
     */
    private Profiler profiler;

    /**
     * Default no-paramter constructor that simply initializes the profiler.
     */
    global AbstractProfiledAsyncJob() {
        this.profiler = new Profiler();
    }

    /**
     * This method contains all of the logic to be executed in a concrete
     * job class. This method must be overwritten in the concrete job class.
     */
    global abstract void execute();

    /**
     * This method is executed when the job is run from a `System.enqueueJob`
     * call. This method takes care of profiling, executing the business logic
     * inside the `execute` method, and also looking for subsequent jobs to
     * enqueue if needed.
     *
     * TODO: To make this job framework more compatible with other
     *       interfaces like Batchable and Schedulable, it would be best to
     *       refactor the profiling, the `execute` call and the `enqueueNext`
     *       call to move into a private method. Also, this would require
     *       a new class field to be created to hold the Job ID returned
     *       by each of the different contexts.
     */
    global void execute(QueueableContext context) {
        
        // Start job profile. We consider the profiler to be a critical
        // part of running the job, so if we can't profile the job we 
        profiler.startProfile(context.getJobId(), this);

        try {
            this.execute();
            this.finishSuccess();
        }
        catch (System.Exception e) {
            profiler.interruptProfile(context.getJobId(), e.getMessage());
            this.finishError(e);
        }

        // End job profile
        profiler.endProfile(context.getJobId());
    }

    /**
     * Do what's necessary to finish the job on an error note. This typically
     * means updating the appropriate job status field to "Error" for
     * all processed records.
     *
     * @param e The caught exception explaining the cause of the error
     */
    global abstract void finishError(System.Exception e);

    /**
     * Do what's necessary to finish the job on a success note. This typically
     * means updating the appropriate job status field to "Success" for
     * all processed records.
     */
    global abstract void finishSuccess();

    /**
     * This class is necessary to work around a limitation in Salesforce
     * where Apex has no equivalent to the Java `Object.getClass()` method.
     * As a result, for dynamic type determination and object construction to
     * work when chaining async job declaratively with custom metadata,
     * every concrete async job class must return its own name via this
     * `getClassName()` implementation.
     *
     * @return the name of the concrete class
     *
     * @see https://docs.oracle.com/javase/7/docs/api/java/lang/Object.html
     * @see https://docs.oracle.com/javase/7/docs/api/java/lang/Class.html
     */
    global abstract String getClassName();
}