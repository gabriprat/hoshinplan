class CompanyComment < GenericComment
  index [:company_id, :created_at]
end