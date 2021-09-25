# Load packages
library(shiny)
library(shinysurveys)
library(googledrive)
library(googlesheets4)

options(
    # whenever there is one account token found, use the cached token
    gargle_oauth_email = TRUE,
    # specify auth tokens should be stored in a hidden directory ".secrets"
    gargle_oauth_cache = ".secrets"
)

# Get the ID of the sheet for writing programmatically
# This should be placed at the top of your shiny app.
# The Google Sheet was created with the following:
# googlesheets4::gs4_create(name = "connect-shiny-google-demo", sheets = "main")
sheet_id <- drive_get("connect-shiny-google-demo")$id

# Define questions in the format of a shinysurvey
survey_questions <- data.frame(
    question = c("This survey is an example accompanying my [blog post on connecting shiny with Google Drive & Google Sheets](https://jdtrat.com/blog/connect-shiny-google/).
                 If you do not wish your data to be saved, please do not complete this survey. 
                 If you would like to view others' responses, please view them [here](https://docs.google.com/spreadsheets/d/1TF2MRzN04jmgiR9o5YSuL5KV8nTV2v4lSmZzNpPFNN4/edit#gid=297418686).
                 The code for this app can be found on my [Github](https://github.com/jdtrat/connect-shiny-google-app).",
                 "What is your favorite food?",
                 "What's your name?"),
    option = NA,
    input_type = c("instructions", "text", "text"),
    input_id = c("disclaimer", "favorite_food", "name"),
    dependence = NA,
    dependence_value = NA,
    required = c(FALSE, TRUE, FALSE)
)

# Define shiny UI
ui <- fluidPage(
    surveyOutput(survey_questions,
                 survey_title = "Hello, World!",
                 survey_description = "A demo survey")
)

# Define shiny server
server <- function(input, output, session) {
    renderSurvey()
    
    observeEvent(input$submit, {
    
        showModal(
            modalDialog(
                p("Thanks for submitting your responses! View the results",
                  a("here", href = "https://docs.google.com/spreadsheets/d/1TF2MRzN04jmgiR9o5YSuL5KV8nTV2v4lSmZzNpPFNN4/edit?usp=sharing"),
                  ".")
            )
        )
        
        response_data <- getSurveyData()
        
        # Read our sheet
        values <- read_sheet(ss = sheet_id, 
                             sheet = "main")
        
        # Check to see if our sheet has any existing data.
        # If not, let's write to it and set up column names. 
        # Otherwise, let's append to it.
        
        if (nrow(values) == 0) {
            sheet_write(data = response_data,
                        ss = sheet_id,
                        sheet = "main")
        } else {
            sheet_append(data = response_data,
                         ss = sheet_id,
                         sheet = "main")
        }
        
    })
    
}

# Run the shiny application
shinyApp(ui, server)
