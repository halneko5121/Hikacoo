class ToppagesController < ApplicationController
 before_action :check_search_validate, only: [:search]
  
  include ToppagesHelper
  
  def index
  end
  
  def search
    
    keyword = params[:search_word][:title]
    puts "keyword ======> #{keyword}"

    # rakuten_web_serviceの使用法に乗っ取りHTTPリクエストを送ってデータを取得
    @items = search_rakuten(keyword) # search_amazon(keyword)
  end
  
  private
  def check_search_validate()
    search_word = params[:search_word][:title]
    if search_word == ""
      flash[:danger] = "検索ワードを入力してください"
      redirect_to root_url
    end
  end  
end
