/**
* Name: BSCS2BZARALAB03
* Based on the internal empty template.
* Author: JOHN PAUL ZARA
* Tags: peer influence, attention, classroom simulation
*/

model Classroom

global {

    int nb_students <- 25;
    float world_size <- 100.0;

    bool is_break <- false;

    // === PART 8 OPTION A: Peer Influence Parameters ===
    float peer_influence_radius <- 10.0;   // how close a peer must be to influence
    float peer_influence_boost  <- 0.03;   // attention gain per high-attention neighbor per cycle

    // monitoring variables
    float avg_attention    -> { student mean_of each.attention };
    float avg_performance  -> { student mean_of each.performance };
    int   high_attention_count -> { student count (each.attention > 0.7) };

    init {
        create student number: nb_students {
            location <- {rnd(world_size), rnd(world_size)};
        }
    }

    reflex classroom_cycle {

        // Toggle break every 15 cycles
        if (cycle mod 15 = 0) {
            is_break <- !is_break;
        }

        // Save CSV
        save [
            cycle,
            avg_attention,
            avg_performance,
            is_break,
            high_attention_count
        ]
        to: "classroom_data.csv"
        format: "csv"
        rewrite: (cycle = 0) ? true : false
        header: true;
    }
}


species student {

    float attention   <- rnd(1.0);
    float performance <- 0.5;
    float mobility    <- rnd(1.0);

    rgb color <- #blue;

    // -------------------------------------------------------
    // PART 8 — OPTION A: Peer Influence
    // Students near high-attention peers increase their attention.
    // -------------------------------------------------------
    reflex peer_influence {

        // Collect neighbours within the influence radius
        list<student> neighbours <- student at_distance peer_influence_radius;

        // Count how many of those neighbours are high-attention (> 0.7)
        int high_attention_neighbours <- neighbours count (each.attention > 0.7);

        // Each high-attention neighbour nudges this student's attention upward
        if (high_attention_neighbours > 0) {
            attention <- min(1.0, attention + peer_influence_boost * high_attention_neighbours);
        }
    }

    reflex update_attention {

        if (is_break) {
            attention <- min(1.0, attention + 0.05);
        } else {
            attention <- max(0.0, attention - 0.05);
        }

        if (attention > 0.8) {
            performance <- min(1.0, performance + 0.01);
        }

        // color coding
        if (attention > 0.7) {
            color <- #green;
        } else if (attention > 0.4) {
            color <- #yellow;
        } else {
            color <- #red;
        }
    }

    reflex move {

        float step_size <- mobility * 2;
        float angle     <- rnd(360.0);

        location <- location + {step_size * cos(angle), step_size * sin(angle)};
    }

    aspect base {
        draw circle(2) color: color;

        // Optional: draw a faint ring to visualise the influence radius
        draw circle(peer_influence_radius) color: rgb(color, 30) border: rgb(color, 80);
    }
}


experiment classroom_simulation type: gui {

    parameter "Initial number of students:"  var: nb_students           min: 10   max: 100;
    parameter "Peer influence radius:"       var: peer_influence_radius  min: 2.0  max: 30.0;
    parameter "Peer influence boost:"        var: peer_influence_boost   min: 0.0  max: 0.1;

    output {

        display main_display type: 2d {
            species student aspect: base;
        }

        monitor "Average Attention"      value: avg_attention;
        monitor "Average Performance"    value: avg_performance;
        monitor "High Attention Count"   value: high_attention_count;

        // Chart showing peer influence effect over time
        display attention_chart type: 2d {
            chart "Attention & Performance Over Time" type: series {
                data "Avg Attention"   value: avg_attention   color: #green;
                data "Avg Performance" value: avg_performance color: #blue;
            }
        }
    }
}
