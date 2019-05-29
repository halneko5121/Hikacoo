module ToppagesHelper
  def search_validate(check_param)
    return check_param_validate(check_param, "検索ワードを入力してください")
  end

  private
  def check_param_validate(value, error_message)
    if value == ""
      return false
    end
    return true
  end  
end
