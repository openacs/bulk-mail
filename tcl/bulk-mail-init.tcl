ad_library {

    initialization for bulk-mail module

    @author yon (yon@openforce.net)
    @creation-date 2002-05-07
    @version $Id$

}

# default interval is 1 minute
ad_schedule_proc -thread t 60 bulk_mail::sweep
