import datetime

class Flight:
    passenger_list = []
    seat_capacity = 150
    
    def __init__(self, flight_number, departure_city, arrival_city, departure_time: datetime):
        self.flight_number = flight_number
        self.departure_city = departure_city
        self.arrival_city = arrival_city
        self.departure_time = departure_time
        
    def add_passenger(self, fullName):
        if self.seat_capacity > 0:
          self.passenger_list.append(fullName)
          self.seat_capacity-=1  
        else:
            print("Flight is full")
            
    def remove_passenger(self, fullName):
        if fullName in self.passenger_list:
          self.passenger_list.remove(fullName) 
          print(f"Successful removal of {fullName}")
          self.seat_capacity+=1 
        else:
            print(f"{fullName} is not on this flight")
            
    def log_flight(self):
        output_file_path = "flight_output.txt"
        with open(file = output_file_path, mode = 'a') as f:
            f.write(f"Flight Number: {self.flight_number} Departure City: {self.departure_city} Arrival City: {self.arrival_city}Flight Number: {self.flight_number}\nNumber of Passengers: {150- self.seat_capacity}")
            
    def check_availability(self) -> int:
        return self.seat_capacity
    
    def __str__(self):
        return f"Flight {self.flight_number} from {self.departure_city} to {self.arrival_city}"
    
departure_time = datetime.datetime(2024, 6, 1)
flight1 = Flight("000111222", "Chicago", "New York City", departure_time=departure_time)

print(flight1)

flight1.add_passenger("Billy Bob")
flight1.add_passenger("Billy Joe")
flight1.remove_passenger("Billy Bob")
flight1.remove_passenger("Sarah")
flight1.log_flight()
flight1.check_availability()