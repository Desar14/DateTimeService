-----------------BEGIN: Script to be run at Publisher 'SERVER-UT05'-----------------
use [triovist]
exec sp_addsubscription @publication = N'triovist_table_repl_microservi', @subscriber = N'SERVER-1C-SQL-1', @destination_db = N'triovist_repl', @subscription_type = N'Push', @sync_type = N'automatic', @article = N'all', @update_mode = N'read only', @subscriber_type = 0
exec sp_addpushsubscription_agent @publication = N'triovist_table_repl_microservi', @subscriber = N'SERVER-1C-SQL-1', @subscriber_db = N'triovist_repl', @job_login = N'21vek\1c', @job_password = N'09Rsdk71', @subscriber_security_mode = 0, @subscriber_login = N'sa', @subscriber_password = N'1q2w3e!', @frequency_type = 64, @frequency_interval = 0, @frequency_relative_interval = 0, @frequency_recurrence_factor = 0, @frequency_subday = 0, @frequency_subday_interval = 0, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 20210609, @active_end_date = 99991231, @enabled_for_syncmgr = N'False', @dts_package_location = N'Distributor'
GO
-----------------END: Script to be run at Publisher 'SERVER-UT05'-----------------

