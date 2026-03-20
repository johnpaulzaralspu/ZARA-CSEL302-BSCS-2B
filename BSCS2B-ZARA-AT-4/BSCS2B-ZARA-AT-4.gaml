/**
* Name: BSCS2B-ZARA-ASSESSMENT-TASK-4
* Based on the internal empty template. 
* Author: johnp
* Tags: 
*/


model classroom_simulation

global {
	float world_size <- 40.0;
 
    // Live dashboard values — these update every step so you can watch the 
    // average score, average energy, and number of inactive students 
    // change in real time as the simulation runs.
    float avg_score -> { student mean_of each.score };
    float avg_energy -> { student mean_of each.energy };
    int inactive_student -> { student count (each.status = "inactive") };
	
	init {
        create student number: 20;
    }
}

// Creating the Student Species
species student {
	int energy <- 5;
    int score <- 0;
    string status <- "active";
    
    // Color coding of ("purple") show as active
    rgb color <- #purple;
    
	// Aspect definition
    aspect base {
        draw circle(2) color: color;
    }
    
    reflex participate when: status = "active" {
		if flip(0.8) {
        	score <- score + 1;
        	energy <- energy - 1;
		}
    }
    // Updating the Status of the students
    reflex update_status {
    	if energy <= 0 {
        	status <- "inactive";
        	// Added color coding, when the status starts to inactivate
        	color <- #red;
    	}
	}
}




experiment classroom_simulation type: gui {
	
	output {
        // The main 2D screen where you can watch the students
        // as purple and red circles moving through the world.
        display main_display type: 2d {
        	species student aspect: base;
        }

 
        // Live dashboard panels — these numbers update every step
        // so you can track the overall state of the simulation at a glance.
        monitor "Average Score" value: avg_score;
        monitor "Average Energy" value: avg_energy;
        monitor "Inactive Students" value: inactive_student;
	}
}