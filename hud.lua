local QuizLab=nil
local BLUE={22,140,255,255}
local GREEN={0,255,117,255}
local BG={7,17,28,232}
local PANEL={13,29,46,255}
local WHITE={242,247,255,255}
local SECONDARY={169,189,209,255}
local RED={255,77,90,255}
local function color(c)
djui_hud_set_color(c[1],c[2],c[3],c[4])
end
local function text(t,x,y,s)
djui_hud_print_text(tostring(t),x,y,s)
end
local function draw_score(x,y,w,h)
color(WHITE)
text("PLACAR",x+24,y+78,1)
color(SECONDARY)
text("SUA PONTUACAO",x+24,y+116,0.5)
color(GREEN)
text(QuizLab.get_score() or 0,x+24,y+140,1)
color(BLUE)
djui_hud_render_rect(x+24,y+177,w-48,2)
color(SECONDARY)
text("#",x+28,y+188,0.45)
text("JOGADOR",x+60,y+188,0.45)
text("PONTOS",x+w-94,y+188,0.45)
local players={}
local count=MAX_PLAYERS or 1
for i=0,count-1 do
local p=gNetworkPlayers and gNetworkPlayers[i]
if p and p.connected then
local score=0
if type(QuizLab.get_player_score)=="function" then
score=QuizLab.get_player_score(i) or 0
elseif i==0 then
score=QuizLab.get_score() or 0
end
players[#players+1]={
index=i,
name=p.name or ("Jogador "..(i+1)),
score=score
}
end
end
table.sort(players,function(a,b)
if a.score==b.score then return a.index<b.index end
return a.score>b.score
end)
local rowY=y+210
local rowH=25
local maxRows=math.max(1,math.floor((h-270)/rowH))
local shown=math.min(#players,maxRows)
for i=1,shown do
local p=players[i]
local py=rowY+(i-1)*rowH
if p.index==0 then
color(GREEN)
djui_hud_render_rect(x+22,py-3,w-44,21)
color(BG)
else
color(WHITE)
end
text(i,x+30,py,0.45)
local name=p.name
if #name>15 then name=string.sub(name,1,14).."." end
text(name,x+60,py,0.45)
text(p.score,x+w-85,py,0.45)
end
if #players==0 then
color(SECONDARY)
text("Nenhum jogador conectado.",x+28,rowY,0.45)
elseif #players>shown then
color(SECONDARY)
text("+"..(#players-shown).." jogadores",x+28,
rowY+shown*rowH,0.4)
end
color(SECONDARY)
text("B - VOLTAR",x+24,y+h-27,0.45)
end
local function draw_settings(x,y,h)
color(WHITE)
text("CONFIGURACOES",x+24,y+82,0.85)
color(SECONDARY)
text("MODO DE RESPOSTA",x+24,y+135,0.5)
color(GREEN)
text("CHAT: A / B / C / D",x+24,y+160,0.55)
color(SECONDARY)
text("PERGUNTAS CARREGADAS",x+24,y+210,0.45)
color(WHITE)
text(QuizLab.get_question_count(),x+24,y+234,0.6)
color(SECONDARY)
text("B - VOLTAR",x+24,y+h-27,0.45)
end
local function draw_pause()
if not QuizLab.is_pause_menu_open() then return end
local w=djui_hud_get_screen_width()
local h=djui_hud_get_screen_height()
local pw,ph=420,390
local x=(w-pw)/2
local y=(h-ph)/2
color({2,7,15,225})
djui_hud_render_rect(0,0,w,h)
color(PANEL)
djui_hud_render_rect(x,y,pw,ph)
color(BLUE)
djui_hud_render_rect(x,y,pw,5)
color(GREEN)
text("QUIZLAB - PAUSADO",x+24,y+22,1)
color(WHITE)
local screen=QuizLab.get_pause_menu_screen()
if screen=="score" then
draw_score(x,y,pw,ph)
return
elseif screen=="settings" then
draw_settings(x,y,ph)
return
end
color(WHITE)
text("PONTOS: "..tostring(QuizLab.get_score()),x+24,y+65,0.7)
local items=QuizLab.get_pause_menu_items()
local selected=QuizLab.get_pause_menu_selection()
for i,item in ipairs(items) do
local iy=y+110+(i-1)*48
if i==selected then
color(GREEN)
djui_hud_render_rect(x+18,iy-5,pw-36,40)
color(BG)
text("> "..item,x+30,iy,0.8)
else
color(WHITE)
text(item,x+38,iy,0.8)
end
end
end
local function draw_quiz_background()
color(BG)
djui_hud_render_rect(25,25,430,250)
color(BLUE)
djui_hud_render_rect(25,25,300,4)
end
local function draw_quiz()
if not QuizLab.is_active() or QuizLab.is_pause_menu_open() then return end
local q=QuizLab.get_current_question()
if not q then return end
local answers=q.answers or {}
draw_quiz_background()
color(WHITE)
text("QUIZLAB",40,42,1.2)
color(GREEN)
text("PONTOS: "..tostring(QuizLab.get_score()),245,44,0.7)
color(SECONDARY)
text("PERGUNTA "..tostring(QuizLab.get_question_index()).."/"..
tostring(QuizLab.get_question_count()),40,80,0.6)
color(WHITE)
text(q.question or "Pergunta invalida.",40,100,0.7)
local letters={"A","B","C","D"}
for i=1,4 do
local answer=answers[i]
if answer~=nil then
local ay=140+(i-1)*27
if QuizLab.has_answer() and QuizLab.get_correct_answer()==i then
color(GREEN)
elseif QuizLab.has_answer() then
color(RED)
else
color(GREEN)
end
text(letters[i]..")",40,ay,0.65)
color(WHITE)
text(answer,65,ay,0.65)
end
end
color(SECONDARY)
text(q.category or "Ciencias",40,250,0.5)
end
local function on_hud_render()
djui_hud_set_resolution(RESOLUTION_DJUI)
djui_hud_set_font(FONT_NORMAL)
QuizLab=_G.QuizLab
if not QuizLab then return end
if QuizLab.is_pause_menu_open() then
draw_pause()
return
end
draw_quiz()
end
hook_event(HOOK_ON_HUD_RENDER,on_hud_render)
