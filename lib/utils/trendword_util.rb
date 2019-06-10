module Utils
  class TrendwordUtil
  
    # クラスメソッド
    def self.search_trand_word()
      
      # 20010101 形式で現在日付を取得
      date = DateTime.now.strftime('%Y%m%d')
      puts "現在日付 => #{date}"
      
      # google トレンド情報を取得
      uri = URI("https://trends.google.com/" + "trends/api/dailytrends" + "?geo=JP" + "&ed=#{date}")
      response_json = Net::HTTP.get(uri)
  
      # なんかゴミデータが残ってるので削除
      response_json[0, 5] = ''
  
      # JSON パース
      response_json = response_json.force_encoding("utf-8")
      response_data = JSON.parse(response_json)
  
=begin
      # テストコード
      File.open('.\Sample.json', 'w+') do |file|
        file.puts response_data
      end
=end
  
      # トレンドデータ取得（トレンドワード）
      trend_word_array = Array.new
      base_data   = response_data["default"]["trendingSearchesDays"][0]
      trend_datas = base_data["trendingSearches"]
      trend_datas.each do |trand_data|
        trend_word_array.push(trand_data["title"]["query"])
      end
  
      return trend_word_array
    end
  end
end