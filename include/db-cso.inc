


public sql_precache()
{
	g_sqltuple = SQL_MakeDbTuple(host, user, pass, db)
	if(!g_sqltuple)
		return false

	return true
}