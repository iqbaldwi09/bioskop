package domain

import "time"

type Showtime struct {
	ID          int       `db:"id" json:"id"`
	BioskopID   int       `db:"bioskop_id" json:"bioskop_id"`
	BioskopName string    `db:"bioskop_name" json:"bioskop_name"`
	MovieID     int       `db:"movie_id" json:"movie_id"`
	MovieTitle  string    `db:"movie_title" json:"movie_title"`
	StartTime   time.Time `db:"start_time" json:"start_time"`
	EndTime     time.Time `db:"end_time" json:"end_time"`
	Status      string    `db:"status" json:"status"`
	Price       float64   `db:"price" json:"price"`
}
