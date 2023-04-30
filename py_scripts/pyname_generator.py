import random

with open("data/first_names.txt") as file:
    first_names = [line.rstrip() for line in file]

with open("data/last_names.txt") as file:
    last_names = [line.rstrip() for line in file]    

count = 30
max_repeat= 3

def generate_with_reps(names:list):
    ret=[]
    while len(ret) < count:
        rep:int = random.randint(1,max_repeat)
        name:str = names[random.randint(0,len(names)-1)]
        if len(ret) + rep > count:
            rep = count - len(ret)
        ret = ret + [name]*rep
    return ret

chosen_first_names = generate_with_reps(first_names)
chosen_last_names = generate_with_reps(last_names)

names = []
for i in range(count):
    done = False
    while not done:
        first_idx = random.randint(0, len(chosen_first_names)-1)
        last_idx = random.randint(0, len(chosen_last_names)-1)
        name = "{} {}".format(first_names[first_idx], last_names[last_idx])
        if name not in names:
            done=True 
    names.append(name )
    print ("%d %d" % (len(chosen_first_names), len(chosen_last_names)))
    del chosen_first_names[first_idx]
    del chosen_last_names[last_idx]

for name in names:
    print(name)
        
