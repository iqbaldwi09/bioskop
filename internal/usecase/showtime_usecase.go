package usecase

import (
	"github.com/iqbaldwi09/bioskop/internal/domain"
	"github.com/iqbaldwi09/bioskop/internal/repository"
)

type ShowtimeUsecase struct {
	repo *repository.ShowtimeRepository
}

func NewShowtimeUsecase(repo *repository.ShowtimeRepository) *ShowtimeUsecase {
	return &ShowtimeUsecase{repo: repo}
}

func (u *ShowtimeUsecase) GetAll() ([]domain.Showtime, error) {
	return u.repo.GetAll()
}

func (u *ShowtimeUsecase) GetByID(id int) (*domain.Showtime, error) {
	return u.repo.GetByID(id)
}

func (u *ShowtimeUsecase) Create(showtime *domain.Showtime) error {
	return u.repo.Create(showtime)
}

func (u *ShowtimeUsecase) Update(showtime *domain.Showtime) error {
	return u.repo.Update(showtime)
}

func (u *ShowtimeUsecase) Delete(id int64) error {
	return u.repo.Delete(id)
}
