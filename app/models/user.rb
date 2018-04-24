class User < ApplicationRecord
    
    has_many :posts
    has_many :post_likes
    has_many :post_comments
    has_many :follows
    has_many :followers, foreign_key: :follow_user_id, class_name: "Follow"
    # バリデーション
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :name, presence: true
    validates :email, presence: true, format: {with: VALID_EMAIL_REGEX}, uniqueness: true
    validates :password, presence: true, length:{minimum: 6}
    #データの保存前に、パスワードを暗号化するメソッド(convert_password)を実行するよう設定
    before_create :convert_password
    
    # パスワードを暗号化するメソッド
    def convert_password
        self.password = User.generate_password(self.password)
    end
    
    def followed_by?(user)
      user.follows.exists?(follow_user_id: self.id)
    end
    
    # パスワードをmd5に変換するメソッド
    def self.generate_password(password)
        # パスワードを適当な文字列をふかして暗号化する
        salt = "h!hgamcRAdh38bajhvgail7yscvb"
        Digest::MD5.hexdigest(salt + password)
    end
end