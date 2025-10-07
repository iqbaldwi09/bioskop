package repository

import (
	"github.com/iqbaldwi09/bioskop/internal/domain"
	"github.com/jmoiron/sqlx"
)

type ShowtimeRepository struct {
	DB *sqlx.DB
}

func NewShowtimeRepository(db *sqlx.DB) *ShowtimeRepository {
	return &ShowtimeRepository{DB: db}
}

func (r *ShowtimeRepository) GetAll() ([]domain.Showtime, error) {
	query := `
		SELECT s.id,s.bioskop_id,b.name AS bioskop_name,s.movie_id,m.title AS movie_title,s.start_time,s.end_time,s.status,s.price
		FROM showtimes s
		JOIN bioskops b ON s.bioskop_id = b.id
		JOIN movies m ON s.movie_id = m.id
	`
	var showtimes []domain.Showtime
	err := r.DB.Select(&showtimes, query)
	return showtimes, err
}

func (r *ShowtimeRepository) GetByID(id int) (*domain.Showtime, error) {
	query := `
		SELECT s.id,s.bioskop_id,b.name AS bioskop_name,s.movie_id,m.title AS movie_title,s.start_time,s.end_time,s.status,s.price
		FROM showtimes s
		JOIN bioskops b ON s.bioskop_id = b.id
		JOIN movies m ON s.movie_id = m.id
		WHERE s.id = ?
	`
	var showtime domain.Showtime
	err := r.DB.Get(&showtime, query, id)
	if err != nil {
		return nil, err
	}
	return &showtime, nil
}

func (r *ShowtimeRepository) Create(s *domain.Showtime) error {
	query := `
		INSERT INTO showtimes (bioskop_id, movie_id, start_time, end_time, status, price)
		VALUES (?, ?, ?, ?, ?, ?)
	`
	_, err := r.DB.Exec(query, s.BioskopID, s.MovieID, s.StartTime, s.EndTime, s.Status, s.Price)
	return err
}

func (r *ShowtimeRepository) Update(s *domain.Showtime) error {
	query := `
		UPDATE showtimes SET bioskop_id = ?, movie_id = ?, start_time = ?, end_time = ?, status = ?, price = ?
		WHERE id = ?
	`
	_, err := r.DB.Exec(query, s.BioskopID, s.MovieID, s.StartTime, s.EndTime, s.Status, s.Price, s.ID)
	return err
}

func (r *ShowtimeRepository) Delete(id int64) error {
	query := `DELETE FROM showtimes WHERE id = ?`
	_, err := r.DB.Exec(query, id)
	return err
}
