
import dash
import dash_core_components as dcc
import dash_html_components as html
from dash.dependencies import Input, Output
import plotly.express as px
import pandas as pd

external_stylesheets = ['https://codepen.io/chriddyp/pen/bWLwgP.css']


app = dash.Dash(__name__, title='InFraudmatics',
		update_title='Calculating...',
		external_stylesheets=external_stylesheets)

# Read the data
df = pd.read_csv("data/claims.csv")

df = pd.DataFrame({
    "Fruit": ["Apples", "Oranges", "Bananas", "Apples", "Oranges", "Bananas"],
    "Amount": [4, 1, 2, 2, 4, 5],
    "City": ["SF", "SF", "SF", "MTL", "MTL", "MTL"]
})

fig = px.bar(df, x="Fruit", y="Amount", color="City", barmode="group")

def description_card():
    """
    :return: A Div containing dashboard title & descriptions.
    """
    return html.Div(
        id="description-card",
        children=[
            html.H5("InFraudmatics", style={"color": "#3412d4", "font-weight": "bold", "font-size": "28px"}),
            html.H3("Welcome to the Dashboard", style={"font-weight": "bold"}),
            html.Div(
                id="Purpose",
                children="Explore potential fraud and cut business loss"
            )
        ]
    )

@app.callback(Output('tabs-example-content', 'children'),
              [Input('tabs-example', 'value')])
def all_pages(tab):
	if tab == "tab-1":
		return 
	elif tab == "tab-2":
		return html.Div(children=[
				html.H3("Have the physician commited fraud in the past?")
		])


app.layout = html.Div(children=[
		html.Div(
			id="left-column",
			className="four columns",
			style={"height": "100%", "width": "30%", "position": "fixed",
				   "z-index": 1, "top": 0, "left": 0, "padding-left": "2%", "padding-right": "2%"},
			children=[description_card()] 
			+ [
				html.Div(
					["initial child"], id="output-clientside",
					style={"display":"none"})]
		),
		html.Div(
			id="right-column",
			style={"padding-left": "30%"},
			children=[
				dcc.Tabs(id='tabs-example', value='tab-1',
				children=[
        		dcc.Tab(label='Morbidity Analysis', value='tab-1',
					children=[
					html.Div(
						children=[html.H4(children="Please select..."),
						html.Label('Dropdown'),
						dcc.Dropdown(
							id='example-dropdown',
							style={"width": "40%"},
							options=[
								{'label': 'Montreal', 'value': 'MTL'},
								{'label': 'San Fransisco', 'value': 'SF'}
							],
							value='MTL'
							),
						html.Div(id='my-output'),
						dcc.Graph(id='example-graph', figure=fig),
						dcc.Graph(id='example-graph-2', figure=fig)])
					]),
        		dcc.Tab(label='Physician History', value='tab-2'),
    		]),
    		html.Div(
				id='tabs-example-content',
			)
		])
])



@app.callback(
		Output(component_id='example-graph', component_property='figure'),
		[Input(component_id='example-dropdown', component_property='value')])
def update_div_1(input_value):
	new_df = df[df["City"] == input_value]
	fig = px.bar(new_df, x="Fruit", y="Amount", color="City", barmode="group")
	return fig

@app.callback(
		Output(component_id='example-graph-2', component_property='figure'),
		[Input(component_id='example-dropdown', component_property='value')])
def update_div_2(input_value):
	new_df = df[df["City"] != input_value]
	fig = px.bar(new_df, x="Fruit", y="Amount", color="Fruit", barmode="group")
	return fig


if __name__ == '__main__':
	app.run_server(debug=True)
