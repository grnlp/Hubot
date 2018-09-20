# Description:
#   Backlog to Slack
#
# Commands:
#   None.

backlogUrl = process.env.HUBOT_BACKLOG_URL

module.exports = (robot) ->
  robot.router.post "/backlog/:room", (req, res) ->
    room = req.params.room
    body = req.body

    console.log 'body type = ' + body.type
    console.log 'room = ' + room

    try
      switch body.type
          when 1
              label = '課題が作成されました'
          when 2, 3
              # 「更新」と「コメント」は実際は一緒に使うので一緒に。
              label = '課題が更新されました'
          when 5
              label = 'wikiが追加されました'
          when 6
              label = 'wikiが更新されました'
          when 8
              label = 'ファイルが追加されました'
          when 9
              label = 'ファイルが更新されました'
          else
              # 課題関連以外はスルー

      # 投稿メッセージを整形
      url = "#{backlogUrl}view/#{body.project.projectKey}-#{body.content.key_id}"
      if body.content.comment?.id?
          url += "#comment-#{body.content.comment.id}"

      message = "*[Backlog] #{label}*\n"
      message += "ＵＲＬ：#{url}\n"
      message += "作成者：#{body.createdUser.name}\n"
      message += "担当者：#{body.content.assignee.name}\n"
      message += "概要　：#{body.content.summary}\n"
      #message += "詳細　：#{body.content.description}\n"
      #message += "ｺﾒﾝﾄ　：#{body.content.comment.content}

      console.log 'message = ' + message
      # Slack に投稿
      if message?
          robot.messageRoom room, message
          res.end "OK"
      else
          robot.messageRoom room, "Backlog integration error."
          res.end "Error"
    catch error
      robot.send
      res.end "Error"
