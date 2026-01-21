from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import text
from app.database import get_db

router = APIRouter(prefix="/establishments", tags=["Establishments"])

@router.get("/nearby")
def get_nearby_establishments(
    lat: float = Query(...),
    lng: float = Query(...),
    radius_km: int = Query(5),
    db: Session = Depends(get_db)
):
    query = text("""
        SELECT
            id,
            name,
            description,
            address,
            whatsapp,
            ST_Distance(
                location,
                ST_MakePoint(:lng, :lat)::geography
            ) / 1000 AS distance_km
        FROM establishments
        WHERE is_active = true
          AND ST_DWithin(
              location,
              ST_MakePoint(:lng, :lat)::geography,
              :radius_m
          )
        ORDER BY distance_km;
    """)

    result = db.execute(
        query,
        {
            "lat": lat,
            "lng": lng,
            "radius_m": radius_km * 1000
        }
    ).mappings().all()

    return result
