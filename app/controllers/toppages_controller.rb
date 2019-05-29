class ToppagesController < ApplicationController
 before_action :check_search_validate, only: [:search]
  
  include ToppagesHelper
  
  def index
  end
  
  def search

    # 何かしら入っていたら全削除
    items = Item.all
    if !items.empty?
      items.each do |item|
        item.destroy
      end
    end

    # 検索
    keyword = params[:search_word][:title]
    puts "keyword ======> #{keyword}"
    @items = search_amazon(keyword, 10) # search_amazon(keyword)
    @items.each do |item|
      # 存在しなければレコード保存
      if Item.find_by(name: item[:name]) == nil
        item_record = Item.new(
          name: "#{item[:name]}", price: "#{item[:price]}",
          image_url: "#{item[:image_url]}", shop_url: "#{item[:shop_url]}"
        )
        item_record.save
      end
    end
  end
  
  def comparison
    item = params[:title]
    
    @rakuten_item = search_rakuten(item, 1)
    @amazon_item = search_amazon(item, 1)
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
