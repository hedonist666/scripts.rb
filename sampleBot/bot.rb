#!/usr/bin/env ruby
require 'telegram/bot'
require 'nokogiri'

HOMEDIR = 'sampleBot'
$token='686474992:AAHlBDTa4KDT4PRbsGDs7YZNH4E56myWC5o'
$fname=File.join HOMEDIR, 'dos.xml'
$lit_file=File.join HOMEDIR, 'lit.txt'
ss={}

welcome_message="чтобы начать тест, отправьте запрос /test,
чтобы ознакомиться со списком, отправьте запрос /read"

def message(bot,id,t)
  bot.api.send_message(chat_id: id, text: t)
end

def telepat(bot,sess)
  ans=Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard:sess.provide, one_time_keyboard: true)
  bot.api.send_message(chat_id: sess.id, text: sess.ask, reply_markup: ans)
end

class Question
  attr_accessor :vopros,:opts,:right
  def initialize(qst,r,o)
    @vopros=qst
    @opts=o
    @right=r
  end
end

def prepare()
  #[Question.new("?",%w[a b c d],"a"),Question.new("?",%w[1 4 8 8],"1")]
  queue=[]
  xml=Nokogiri::Slop (File.open($fname).read)
  xml.document.root.question.each do |q|
    opts=[]
    q.opt.each do |opt|
      opts<<opt.content
    end
    queue<<Question.new(q.attribute("name").value,
                        q.attribute("ans").value,opts)
  end
  return queue
end

test = prepare()

class Session
  attr_accessor :id,:score

  def initialize(id,qu)
    @id=id
    @queue=qu
    @len=qu.length-1
    @current=-1
    @score=0
  end

  def provide
    @queue[@current+=1].opts
  end

  def ask
    @queue[@current].vopros
  end

  def validate(t)
    @score+=1 if t==@queue[@current].right
  end

  def left?
    return true if @current<@len
    return false
  end

end

Telegram::Bot::Client.run($token) do |bot|
    bot.listen do |m|
      case m.text
      when '/start'
        message(bot,m.chat.id,welcome_message)
      when '/read'
        message(bot,m.chat.id,File.open($lit_file).read)
      when '/test'
        ss.merge!(m.chat.id=>Session.new(m.chat.id,test)) 
        telepat(bot,ss[m.chat.id])
      else
        if ss.has_key?(m.chat.id)
          ss[m.chat.id].validate(m.text)
          if ss[m.chat.id].left?
            telepat(bot,ss[m.chat.id])
          else
            message(bot,m.chat.id,"we're done, your score: #{ss[m.chat.id].score}")
            ss.delete(m.chat.id)
          end
        end
      end
    end
end
