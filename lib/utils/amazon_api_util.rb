module Utils
  class AmazonApiUtil
    
    # クラスメソッド
    def self.scraping_search_amazon_site(keyword, category, count)
  
      # 検索キーワードは空白を「+」に変換する
      keyword = keyword.gsub(" ", "+")
  
      # URL設定
      base_url        = "https://paboo.net/result/"
      search_word     = URI.encode(keyword)
      category_str    = "&category=#{category}"
      request_url     = base_url + "?a_page=1&r_page=1&search=" + "#{search_word}" + "#{category_str}"
  
      # スクレイピング先のURL
      charset = nil
      html = OpenURI.open_uri(URI(request_url)) do |f|
        charset = f.charset     # 文字種別を取得
        f.read                  # htmlを読み込んで変数htmlに渡す
      end
  
      # htmlをパース(解析)してオブジェクトを生成
      doc = Nokogiri::HTML.parse(html, nil, charset)
  
      # 指定件数の情報を取得
      array_items = Array.new
      count.times do |index|
        item_value = Hash.new
        
        # jan code
        doc.xpath("//*[@id='ama_res_in']/article[#{index+1}]/div/div/ul/li[2]/a").each do |node|
          value_string = node.attributes["href"].value
          
          # 不要な文字列を削除する
          value_array  = value_string.split(/(\?|\&)/)
          delete_list = ["/compare/", "?", "&"]
          value_array.delete_if do |str|
            delete_list.include?(str)
          end
          
          # 配列から「ean code」の要素だけ取得
          ean_code = value_array.select { |x|
            x[/(ean\=.*)/, 0]
          }
          ean_code = ean_code[0]
          ean_code[0, 4] = ''
          item_value[:jan_code] = ean_code
        end
      
        # Image URL
        doc.xpath("//*[@id='ama_res_in']/article[#{index+1}]/div/a/img").each do |node|
          item_value[:image_url] = node.attributes["src"].value
        end
        # Title / Shop URL
        doc.xpath("//*[@id='ama_res_in']/article[#{index+1}]/dl/dt/a").each do |node|
          item_value[:name] = node.children.text
          item_value[:shop_url] = node.attributes["href"].value
        end
        # Sales Lank
        correct_index = 0
        doc.xpath("//*[@id='ama_res_in']/article[#{index+1}]/dl/dd[1]").each do |node|
          if !node.children.text.include?("SalesRank")
            correct_index += -1
          end
        end
        
        # Price
        price_str = "//*[@id='ama_res_in']/article[#{index+1}]/dl/dd[#{3 + correct_index}]/span"
        doc.xpath("#{price_str}").each do |node|
          item_value[:price] = node.children.text 
        end
  
        # Price が無い場合
        if item_value[:price] == nil
          correct_index += -1
        end
  
        # Sales Date
        sales_date_str = "//*[@id='ama_res_in']/article[#{index+1}]/dl/dd[#{4 + correct_index}]"
        doc.xpath("#{sales_date_str}").each do |node|
          # 「発売日」を消したい
          temp_value = node.children.text
          temp_value[0, 5] = ''
          item_value[:sales_date] = temp_value
        end
        if !item_value.empty?
          array_items.push(item_value)
        end
      end
  
      return array_items
    end
  end
end