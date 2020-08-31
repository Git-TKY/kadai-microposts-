class User < ApplicationRecord
  before_save { self.email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  
  has_many :microposts
  
  has_many :relationships
  has_many :followings, through: :relationships, source: :follow
  has_many :reverses_of_relationship, class_name: 'Relationship', foreign_key: 'follow_id'
  has_many :followers, through: :reverses_of_relationship, source: :user
  
  def follow(other_user)
    unless self == other_user
      self.relationships.find_or_create_by(follow_id: other_user.id)
    end
  end

  def unfollow(other_user)
    relationship = self.relationships.find_by(follow_id: other_user.id)
    relationship.destroy if relationship
  end

  #すでにフォローしているか確認
  def following?(other_user)
    self.followings.include?(other_user)
    #自身がフォローしているユーザ情報を取得して、これからフォローしたい人が含まれているか判定
  end
  
  def feed_microposts
    Micropost.where(user_id: self.following_ids + [self.id])
    # following_ids は User モデルの has_many :followings, ... によって自動的に生成されるメソッド
    # User がフォローしている User の id の配列を取得
    # 自分自身の self.id もデータ型を合わせるために [self.id] と配列に変換して、追加
  end
  
end
