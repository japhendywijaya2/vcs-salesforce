public with sharing class CustomException extends Exception {

    // Deliberately empty
    public static void exceptionHandling(Database.SaveResult[] saveResult){
        for(Database.SaveResult item : saveResult){
            if(!item.isSuccess()){
                for(Database.Error err : item.getErrors()){
                    throw new CustomException(err.getMessage());
                }
            }
        }
    }

    public static void printErrorInfo(String errLocation, Exception err){
        System.Debug('\n\nError @' + errLocation);
        System.Debug('Error Message: ' + err.getMessage());
        System.Debug('Error Line: ' + err.getLineNumber());
    }
}