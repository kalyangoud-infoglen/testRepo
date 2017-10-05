/**
 * This interface should be implemented by any result-style class that
 * is used to gracefully capture the result of a complex operation, such
 * as a web service callout.
 *
 * This is modeled after the native `Database.SaveResult` class.
 */
global interface Result {

    /**
     * @return whether the operation was successful
     */
    Boolean isSuccess();
}