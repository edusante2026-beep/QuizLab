-- QuizLab
-- base.lua
-- Nucleo local do quiz

local Questions = require("questions")
local Base = {}

--------------------------------------------------
-- ESTADO LOCAL
--------------------------------------------------

local active = false
local questionIndex = 0
local correctAnswer = 0
local answerReceived = false
local score = 0
local playerAnswer = 0

--------------------------------------------------
-- PERGUNTA ATUAL
--------------------------------------------------

function Base.get_current_question()
    if questionIndex < 1 then
        return nil
    end

    return Questions[questionIndex]
end

function Base.get_question_index()
    return questionIndex
end

function Base.get_question_count()
    return #Questions
end

function Base.get_correct_answer()
    return correctAnswer
end

function Base.has_answer()
    return answerReceived
end

function Base.is_active()
    return active
end

function Base.get_score()
    return score
end

function Base.get_player_score(index)
    if index ~= 0 then
        return 0
    end

    return score
end

function Base.get_player_answer(index)
    if index ~= 0 then
        return 0
    end

    return playerAnswer
end

--------------------------------------------------
-- SORTEAR PERGUNTA
--------------------------------------------------

function Base.select_question()
    if #Questions == 0 then
        return false
    end

    local index = math.random(1, #Questions)
    local question = Questions[index]
    local correct = question and question.correct or 0

    if correct < 1 or correct > 4 then
        return false
    end

    questionIndex = index
    correctAnswer = correct
    answerReceived = false
    playerAnswer = 0

    return true
end

--------------------------------------------------
-- INICIAR QUIZ
--------------------------------------------------

function Base.start()
    if active then
        return false
    end

    score = 0
    answerReceived = false
    playerAnswer = 0

    if not Base.select_question() then
        djui_chat_message_create(
            "\\#FF4D5A\\QuizLab: nao foi possivel carregar as perguntas."
        )
        return false
    end

    active = true
    return true
end

--------------------------------------------------
-- PROXIMA PERGUNTA
--------------------------------------------------

function Base.next()
    if not active then
        return false
    end

    return Base.select_question()
end

--------------------------------------------------
-- ENCERRAR QUIZ
--------------------------------------------------

function Base.stop()
    active = false
    questionIndex = 0
    correctAnswer = 0
    answerReceived = false
    playerAnswer = 0
    score = 0

    return true
end

--------------------------------------------------
-- VERIFICAR RESPOSTA
--------------------------------------------------

function Base.check_answer(playerIndex, message)
    if not active or playerIndex ~= 0 then
        return nil
    end

    if answerReceived or type(message) ~= "string" then
        return nil
    end

    local answer = message:lower():match("^%s*(.-)%s*$")

    local answers = {
        a = 1,
        b = 2,
        c = 3,
        d = 4
    }

    local selected = answers[answer]

    if not selected then
        return nil
    end

    playerAnswer = selected
    answerReceived = true

    if selected == correctAnswer then
        score = score + 1
        return true
    end

    return false
end

--------------------------------------------------
-- API
--------------------------------------------------

_G.QuizLabBase = Base

return Base
