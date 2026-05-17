import json



def text_data_write(text,file):
    with open(file,'w') as f:
        json.dump(text,f)

def text_data_load(file):
    with open(file,'r') as f:
        return json.load(f)
    

    

        
