# Backfill legacy constants expected by Rails 4.2 and older gems when using pg >= 1.0
if defined?(PG)
  PGconn   = PG::Connection unless defined?(PGconn)
  PGresult = PG::Result     unless defined?(PGresult)
  PGError  = PG::Error      unless defined?(PGError)
end


